# MediaConch_SourceCode/Release/PrepareSource.sh
# Prepare the source of MediaConch

# Copyright (c) MediaArea.net SARL. All Rights Reserved.
# Use of this source code is governed by a BSD-style license that can
# be found in the License.html file in the root of the source tree.

function _get_source () {

    local RepoURL

    if [ $(b.opt.get_opt --repo) ]; then
        RepoURL=$(sanitize_arg $(b.opt.get_opt --repo))
    else
        RepoURL="https://github.com/MediaArea/"
    fi

    cd $WPath
    if ! b.path.dir? repos; then
        mkdir repos
    fi

    # Determine where are the sources of MediaConch
    if [ $(b.opt.get_opt --source-path) ]; then
        MC_source=$(sanitize_arg $(b.opt.get_opt --source-path))
    else
        getRepo MediaConch_SourceCode $RepoURL $WPath/repos
        MC_source=$WPath/repos/MediaConch_SourceCode
    fi

    # MediaInfoLib (will also bring ZenLib and zlib)
    cd $(b.get bang.working_dir)
    $(b.get bang.src_path)/bang run PrepareSource.sh -p MediaInfoLib -r $RepoURL -w $WPath -${Target} -na -nc

}

function _compil_unix_cli () {

    echo
    echo "Generate the MC CLI directory for compilation under Linux:"
    echo "1: copy what is wanted..."

    cd $WPath/MC
    mkdir MediaConch_CLI${Version}_GNU_FromSource
    cd MediaConch_CLI${Version}_GNU_FromSource

    cp -r $MC_source MediaConch
    mv MediaConch/Project/GNU/CLI/AddThisToRoot_CLI_compile.sh CLI_Compile.sh
    chmod +x CLI_Compile.sh

    # MediaInfoLib and ZenLib
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/MediaInfoLib .
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/ZenLib .

    echo "2: remove what isn't wanted..."
    cd MediaConch
        rm -fr .cvsignore .git*
        #rm -fr Release
        rm -fr debian
        cd Project
            rm -f GNU/mediaconch.dsc GNU/mediaconch.spec
            rm -fr GNU/GUI
            rm -fr MSVC2013 OBS Qt
        cd ..
        rm -fr Source/GUI
    cd ..

    echo "3: Autogen..."
    cd MediaConch/Project/GNU/CLI
    sh autogen > /dev/null 2>&1

    if $MakeArchives; then
        echo "4: compressing..."
        cd $WPath/MC
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        (XZ_OPT=-9e tar -cJ --owner=root --group=root -f ../archives/MediaConch_CLI${Version}_GNU_FromSource.txz MediaConch_CLI${Version}_GNU_FromSource)
    fi

}

function _compil_unix_gui () {

    echo
    echo "Generate the MC GUI directory for compilation under Linux:"
    echo "1: copy what is wanted..."

    cd $WPath/MC
    mkdir MediaConch_GUI${Version}_GNU_FromSource
    cd MediaConch_GUI${Version}_GNU_FromSource

    cp -r $MC_source MediaConch
    mv MediaConch/Project/GNU/GUI/AddThisToRoot_GUI_compile.sh GUI_Compile.sh
    chmod +x GUI_Compile.sh

    # Dependencies
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/MediaInfoLib .
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/ZenLib .

    echo "2: remove what isn't wanted..."
    cd MediaConch
        rm -fr .cvsignore .git*
        #rm -fr Release
        rm -fr debian
        cd Project
            rm -f GNU/mediaconch.dsc GNU/mediaconch.spec
            rm -fr GNU/CLI
            rm -fr MSVC2013 OBS
        cd ..
    cd ..

    if $MakeArchives; then
        echo "4: compressing..."
        cd $WPath/MC
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        (XZ_OPT=-9e tar -cJ --owner=root --group=root -f ../archives/MediaConch_GUI${Version}_GNU_FromSource.txz MediaConch_GUI${Version}_GNU_FromSource)
    fi

}

function _compil_windows () {

    echo
    echo "Generate the MC directory for compilation under Windows:"
    echo "1: copy what is wanted..."

    cd $WPath/MC
    mkdir mediaconch${Version}_AllInclusive
    cd mediaconch${Version}_AllInclusive

    cp -r $MC_source MediaConch

    # MediaInfoLib and ZenLib
    cp -r $WPath/MIL/libmediainfo_AllInclusive/MediaInfoLib .
    cp -r $WPath/MIL/libmediainfo_AllInclusive/ZenLib .

    # Dependency : zlib
    cp -r $WPath/MIL/libmediainfo_AllInclusive/zlib .

    echo "2: remove what isn't wanted..."
    cd MediaConch
        rm -f .cvsignore .gitignore
        rm -fr .git
        #rm -fr Release
        rm -fr debian
        cd Project
            rm -fr GNU Mac OBS
        cd ..
    cd ..

    if $MakeArchives; then
        echo "3: compressing..."
        cd $WPath/MC
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        7z a -t7z -mx=9 -bd ../archives/mediaconch${Version}_AllInclusive.7z mediaconch${Version}_AllInclusive >/dev/null
    fi

}

function _linux_packages () {

    echo
    echo "Generate the MC directory for Linux packages creation:"
    echo "1: copy what is wanted..."

    cd $WPath/MC

    cp -r $MC_source MediaConch

    echo "2: remove what isn't wanted..."
    cd MediaConch
        rm -fr .cvsignore .git*
        #rm -fr Release
        cd Project
            rm -fr MSVC2013 Mac Qt
        cd ..
    cd ..

    if $MakeArchives; then
        echo "3: compressing..."
        cd $WPath/MC
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        (XZ_OPT=-9 tar -cJ --owner=root --group=root -f ../archives/mediaconch${Version}.txz MediaConch)
    fi

}

function btask.PrepareSource.run () {

    local MC_source

    cd $WPath

    # Clean up
    rm -fr archives
    rm -fr repos
    mkdir repos
    rm -fr ZL
    rm -fr MIL
    rm -fr MC
    mkdir MC

    _get_source

    if [ "$Target" = "cu" ]; then
        _compil_unix_cli
        _compil_unix_gui
    fi
    if [ "$Target" = "cw" ]; then
        _compil_windows
    fi
    if [ "$Target" = "lp" ]; then
        _linux_packages
    fi
    if [ "$Target" = "all" ]; then
        _compil_unix_cli
        _compil_unix_gui
        _compil_windows
        _linux_packages
    fi
    
    if $CleanUp; then
        cd $WPath
        rm -fr repos
        rm -fr ZL
        rm -fr MIL
        rm -fr MC
    fi

}

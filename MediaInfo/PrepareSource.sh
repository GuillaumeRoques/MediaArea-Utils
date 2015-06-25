# MediaInfo/Release/PrepareSource.sh
# Prepare the source of MediaInfo

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

    # Determine where are the sources of MediaInfo
    if [ $(b.opt.get_opt --source-path) ]; then
        MI_source=$(sanitize_arg $(b.opt.get_opt --source-path))
    else
        getRepo MediaInfo $RepoURL $WPath/repos
        MI_source=$WPath/repos/MediaInfo
    fi

    # MediaInfoLib (will also bring ZenLib and zlib)
    cd $(b.get bang.working_dir)
    $(b.get bang.src_path)/bang run PrepareSource.sh -p MediaInfoLib -r $RepoURL -w $WPath -${Target} -na -nc

}

function _compil_unix_cli () {

    echo
    echo "Generate the MI CLI directory for compilation under Linux:"
    echo "1: copy what is wanted..."

    cd $WPath/MI
    mkdir MediaInfo_CLI${Version}_GNU_FromSource
    cd MediaInfo_CLI${Version}_GNU_FromSource

    cp -r $MI_source .
    mv MediaInfo/Project/GNU/CLI/AddThisToRoot_CLI_compile.sh CLI_Compile.sh
    chmod +x CLI_Compile.sh

    # Dependencies
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/ZenLib .
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/MediaInfoLib .

    echo "2: remove what isn't wanted..."
    cd MediaInfo
        rm -fr .cvsignore .git*
        rm -f History_GUI.txt
        #rm -fr Release
        rm -fr debian
        cd Project
            rm -f GNU/mediainfo.dsc GNU/mediainfo.spec
            rm -fr GNU/GUI
            rm -fr BCB QMake CodeBlocks
            rm -fr MSVC2008 MSVC2010 MSVC2012 MSVC2013
        cd ..
        rm -fr Source/GUI
    cd ..

    echo "3: Autogen..."
    cd MediaInfo/Project/GNU/CLI
    sh autogen > /dev/null 2>&1

    if $MakeArchives; then
        echo "4: compressing..."
        cd $WPath/MI
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        (XZ_OPT=-9e tar -cJ --owner=root --group=root -f ../archives/MediaInfo_CLI${Version}_GNU_FromSource.txz MediaInfo_CLI${Version}_GNU_FromSource)
    fi

}

function _compil_unix_gui () {

    echo
    echo "Generate the MI GUI directory for compilation under Linux:"
    echo "1: copy what is wanted..."

    cd $WPath/MI
    mkdir MediaInfo_GUI${Version}_GNU_FromSource
    cd MediaInfo_GUI${Version}_GNU_FromSource

    cp -r $MI_source .
    mv MediaInfo/Project/GNU/GUI/AddThisToRoot_GUI_compile.sh GUI_Compile.sh
    chmod +x GUI_Compile.sh

    # Dependencies
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/ZenLib .
    cp -r $WPath/MIL/MediaInfo_DLL_GNU_FromSource/MediaInfoLib .

    echo "2: remove what isn't wanted..."
    cd MediaInfo
        rm -fr .cvsignore .git*
        rm -f History_CLI.txt
        #rm -fr Release
        rm -fr debian
        cd Project
            rm -f GNU/mediainfo.dsc GNU/mediainfo.spec
            rm -fr GNU/CLI
            rm -fr BCB QMake CodeBlocks
            rm -fr MSVC2008 MSVC2010 MSVC2012 MSVC2013
        cd ..
    cd ..

    echo "3: Autogen..."
    cd MediaInfo/Project/GNU/GUI
    sh autogen > /dev/null 2>&1

    if $MakeArchives; then
        echo "4: compressing..."
        cd $WPath/MI
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        (XZ_OPT=-9e tar -cJ --owner=root --group=root -f ../archives/MediaInfo_GUI${Version}_GNU_FromSource.txz MediaInfo_GUI${Version}_GNU_FromSource)
    fi

}

function _compil_windows () {

    echo
    echo "Generate the MI directory for compilation under Windows:"
    echo "1: copy what is wanted..."

    cd $WPath/MI
    mkdir mediainfo${Version}_AllInclusive
    cd mediainfo${Version}_AllInclusive

    cp -r $MI_source .

    # Dependencies
    cp -r $WPath/MIL/libmediainfo_AllInclusive/ZenLib .
    cp -r $WPath/MIL/libmediainfo_AllInclusive/MediaInfoLib .
    cp -r $WPath/MIL/libmediainfo_AllInclusive/zlib .

    echo "2: remove what isn't wanted..."
    cd MediaInfo
        rm -f .cvsignore .gitignore
        rm -fr .git
        #rm -fr Release
        rm -fr debian
        cd Project
            rm -fr GNU Mac Solaris OBS
        cd ..
        rm -fr Source/GUI/Cocoa
    cd ..

    if $MakeArchives; then
        echo "3: compressing..."
        cd $WPath/MI
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        7z a -t7z -mx=9 -bd ../archives/mediainfo${Version}_AllInclusive.7z mediainfo${Version}_AllInclusive >/dev/null
    fi

}

function _linux_packages () {

    echo
    echo "Generate the MI directory for Linux packages creation:"
    echo "1: copy what is wanted..."

    cd $WPath/MI
    cp -r $MI_source .

    echo "2: remove what isn't wanted..."
    cd MediaInfo
        rm -fr .cvsignore .git*
        #rm -fr Release
        cd Project
            rm -fr BCB QMake CodeBlocks
            rm -fr MSVC2008 MSVC2010 MSVC2012 MSVC2013
            rm -fr Mac Solaris OBS
        cd ..
    cd ..

    if $MakeArchives; then
        echo "3: compressing..."
        cd $WPath/MI
        if ! b.path.dir? ../archives; then
            mkdir ../archives
        fi
        (XZ_OPT=-9 tar -cJ --owner=root --group=root -f ../archives/mediainfo${Version}.txz MediaInfo)
    fi

}

function btask.PrepareSource.run () {

    local MI_source

    cd $WPath

    # Clean up
    rm -fr archives
    rm -fr repos
    mkdir repos
    rm -fr ZL
    rm -fr MIL
    rm -fr MI
    mkdir MI

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
        rm -fr MI
    fi

}

post_install() {
    setup_configuration "${PEARL_PKGVARDIR}/Xdefaults" \
        _new_xdefaults _apply_xdefaults _unapply_xdefaults
}

post_update() {
    post_install
}

pre_remove() {
    _unapply_xdefaults
}

_new_xdefaults() {
    warn "The following procedure will overwrite the files $HOME/.Xdefaults and $HOME/.Xresources"

    if osx_detect
    then
        if command -v fc-list &> /dev/null
        then
            warn "You need to have fontconfig installed. Run: brew install fontconfig"
        fi
    fi

    local fontlist=()
    IFS=$'\n'
    # Disable pipefail as this may fail if list of fonts is empty
    set +o pipefail
    for font in $(fc-list | grep -E "^/(home|Users)" | grep -i mono | cut -d: -f2 | sort -u)
    do
        fontlist+=("$font")
    done
    set -o pipefail

    if [[ -z $fontlist ]]
    then
        error "Fail on setting the font name. You need to install a font first!"
        return 1
    fi

    local fontname=$(choose "Which mono font would you like (for full list run fc-list)?" "${fontlist[0]}" "${fontlist[@]}")
    local fontsize=$(input "Which font size would you like?" "18")
    sed -e "s/<FONTNAME>/$fontname/g" -e "s/<FONTSIZE>/$fontsize/g" "$PEARL_PKGDIR/Xdefaults-template" > "$PEARL_PKGVARDIR/Xdefaults"

    local themes=()
    local thm
    for thm in "$PEARL_PKGDIR/"Xdefaults-theme-*
    do
        themes+=($(basename "${thm/Xdefaults-theme-/}"))
    done

    local theme=$(choose "Which theme would you like?" "zenburn" "${themes[@]}")
    cat "$PEARL_PKGDIR/Xdefaults-theme-$theme" >> "$PEARL_PKGVARDIR/Xdefaults"

    # Check the Xdefaults file for syntax errors, like ' chars in comments
    if command -v xrdb > /dev/null
    then
      xrdb -n $PEARL_PKGVARDIR/Xdefaults > /dev/null
    fi
    return 0
}

_apply_xdefaults() {
    # We want to set up both Xdefaults and Xresources; here's why:
    #   http://superuser.com/q/243914/436719
    cp -f $PEARL_PKGVARDIR/Xdefaults $HOME/.Xdefaults
    cp -f $PEARL_PKGVARDIR/Xdefaults $HOME/.Xresources

    if command -v xrdb > /dev/null
    then
        info "Loading configuration..."
        xrdb -load ~/.Xdefaults
    fi
    return 0
}

_unapply_xdefaults() {
    [[ -f $HOME/.Xdefaults ]] && rm -f $HOME/.Xdefaults
    [[ -f $HOME/.Xresources ]] && rm -f $HOME/.Xresources
    return 0
}


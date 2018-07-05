post_install() {
    pearl emerge ${PEARL_PKGREPONAME}/fonts

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

    local fontname=$(input "Which font would you like?" "Ubuntu Mono derivative Powerline")
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



post_install() {
    warn "The following procedure will overwrite the files $HOME/.Xdefaults and $HOME/.Xresources"

    info "dot-gtk package requires fonts to be installed into the system."
    info "Use the fonts Pearl package:"
    info "> pearl install fonts"

    local fontname=$(input "Which font would you like?" "Ubuntu Mono derivative Powerline")
    local fontsize=$(input "Which font size would you like?" "18")
    sed -e "s/<FONTNAME>/$fontname/g" -e "s/<FONTSIZE>/$fontsize/g" "$PEARL_PKGDIR/Xdefaults-template" > "$PEARL_PKGVARDIR/Xdefaults"
    local theme=$(choose "Which theme would you like?" "zenburn" "solarized" "solarized-light" "zenburn")
    cat "$PEARL_PKGDIR/Xdefaults-color-$theme" >> "$PEARL_PKGVARDIR/Xdefaults"

    # Check the Xdefaults file for syntax errors, like ' chars in comments
    if command -v xrdb >/dev/null
    then
      xrdb -n $PEARL_PKGVARDIR/Xdefaults >/dev/null
    fi

    # We want to set up both Xdefaults and Xresources; here's why:
    #   http://superuser.com/q/243914/436719
    cp -f $PEARL_PKGVARDIR/Xdefaults $HOME/.Xdefaults
    cp -f $PEARL_PKGVARDIR/Xdefaults $HOME/.Xresources

    if command -v xrdb >/dev/null
    then
        info "Loading configuration..."
        xrdb -load ~/.Xdefaults
    fi
}

post_update() {
    post_install
}

pre_remove() {
    rm $HOME/.Xdefaults
    rm $HOME/.Xresources
}

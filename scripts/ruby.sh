#!/bin/bash

switch_to_latest_ruby() {
  # shellcheck disable=SC1091
  . /usr/local/share/chruby/chruby.sh
  chruby "ruby-$(latest_installed_ruby)"
}

#!/bin/sh

if which subl >/dev/null; then
  echo "skip sublime 3 installation"
else
  echo "sublime 3 installation"
  add-apt-repository ppa:webupd8team/sublime-text-3
  apt-get update -qq
  apt-get install -y sublime-text-installer
fi

# cd ~/.config/sublime-text-3/Packages
# git clone https://github.com/wbond/sublime_package_control.git "Package Control"
# cd "Package Control"
# git checkout python3

# ## Sublime Text 3 Packages
# - package control
#   - https://packagecontrol.io/installation#st3
# - autocomplete
#   - https://github.com/alienhard/SublimeAllAutocomplete
# - sublime linter
#   - https://github.com/SublimeLinter
#   - https://github.com/SublimeLinter/SublimeLinter3
#   - http://sublimelinter.readthedocs.org/en/latest/
# - vintageous
#   -https://github.com/guillermooo/Vintageous
# - git
#   - https://packagecontrol.io/packages/GitGutter
# - json
#   - https://packagecontrol.io/packages/JSONLint
#   - https://github.com/dzhibas/SublimePrettyJson
# - ruby & rails
#   - https://mattbrictson.com/sublime-text-3-recommendations
#   - https://github.com/SublimeText/RSpec
#   - https://packagecontrol.io/packages/DocBlockr
#   - https://github.com/SublimeLinter/SublimeLinter-ruby
#   - https://github.com/SublimeLinter/SublimeLinter-rubocop
# - OSX
#   - Dash App
#     - https://kapeli.com/dash
#   - DashDoc
#     - https://github.com/farcaller/DashDoc#readme

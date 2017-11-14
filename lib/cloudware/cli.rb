#==============================================================================
# Copyright (C) 2017 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Cloudware.
#
# Alces Cloudware is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Cloudware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces Cloudware, please visit:
# https://github.com/alces-software/cloudware
#==============================================================================
require 'commander'
require 'terminal-table'

module Cloudware

  class CLI
    extend Commander::UI
    extend Commander::UI::AskForClass
    extend Commander::Delegates

    program :name, 'cloudware'
    program :version, '0.0.1'
    program :description, 'Cloud orchestration tool'

    command :'infrastructure create' do |c|
      c.syntax = 'cloudware infrastructure create [options]'
      c.description = 'Interact with infrastructure groups'
      c.option '--name NAME', String, 'Infrastructure identifier'
      c.option '--provider NAME', String, 'Provider name'
      c.option '--region NAME', String, 'Region name to deploy into'
      c.action { |args, options|
        i = Cloudware::Infrastructure.new
        i.name="#{options.name}"
        i.provider="#{options.provider}"
        i.region="#{options.region}"
        i.create
      }
    end
  end

end

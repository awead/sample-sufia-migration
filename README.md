# Sample Sufia Migration

A sample Sufia application that outlines the steps required for upgrading from Sufia 5 to 6 and migrating
data from Fedora 3 to 4.

## Basic Steps

Upgrading your Sufia application is outlined in the [release notes](https://github.com/projecthydra/sufia/releases)

Migrating the data from Fedora 3 to Fedora 4 is desribed in this [wiki page](https://github.com/projecthydra/sufia/wiki/Migrating-to-Fedora-4-with-fedora-migrate)

Otherwise, refer to the commit history in this repo for the specific changes.

## Custom Rake Task

Note the custom rake task that you should use to migrate your data:

``` ruby
require 'fedora-migrate'

module FedoraMigrate::Hooks
  # Apply depositor metadata from Sufia's properties datastream under Fedora 3
  def before_object_migration
    xml = Nokogiri::XML(source.datastreams["properties"].content)
    target.apply_depositor_metadata xml.xpath("//depositor").text
  end
end

desc "Migrates all objects in a Sufia-based application"
task migrate: :environment do
  migration_options = {convert: "descMetadata", application_creates_versions: true}
  migrator = FedoraMigrate.migrate_repository(namespace: "sufia", options: migration_options )
  migrator.report.save
  Rake::Task["sufia:migrate:proxy_deposits"].invoke
  Rake::Task["sufia:migrate:audit_logs"].invoke
end
```

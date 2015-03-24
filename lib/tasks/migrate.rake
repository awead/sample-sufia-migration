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

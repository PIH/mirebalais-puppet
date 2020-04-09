namespace :update_ci_import_map do
    desc 'Updates the import map to the given values'
    task :default do
      run("logger -s #{esm} #{url}")
    end
  end

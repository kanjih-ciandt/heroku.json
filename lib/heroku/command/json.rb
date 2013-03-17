require 'heroku/command/run'
require 'exporter'

# invoke commands without fucking "run"
class Heroku::Command::Json < Heroku::Command::Run

  def import
    puts 'Import'
  end

  alias_command 'import', 'json:import'

  def export
    exporter = Exporter.new(api, app)
    json = exporter.export
    File.write('heroku.json', JSON.pretty_generate(json))
  end

  alias_command 'export', 'json:export'


  private

  def get_environment_variables app

    # Get the config variables for the current app
    res = api.get_config_vars(app)
    raise "Fail getting env : #{res.status}" unless res.status == 200


    env = {
        whitelist: {},
        to_query: {},
    }

    res.body.each do |key, value|
      # Skip if it's blacklisted
      next if HerokuJson::ENV_BLACKLIST.include?(key)

      # Put it in the right place for querying later
      if HerokuJson::ENV_WHITELIST.include?(key)
        env[:whitelist][key] = value
      else
        env[:to_query][key] = value
      end

    end

    env

  end

end


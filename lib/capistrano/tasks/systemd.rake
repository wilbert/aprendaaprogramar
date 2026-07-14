# frozen_string_literal: true

namespace :deploy do
  desc "Restart the application (Puma) via systemd"
  task :restart do
    on roles(:app), in: :sequence do
      execute :sudo, :systemctl, :restart, "aprendaaprogramar-puma"
    end
  end

  desc "Show status of the application service"
  task :status do
    on roles(:app) do
      execute :sudo, :systemctl, "--no-pager", :status, "aprendaaprogramar-puma",
              raise_on_non_zero_exit: false
    end
  end
end

after "deploy:publishing", "deploy:restart"

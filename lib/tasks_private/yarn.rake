namespace :yarn do
  desc "install yarn dependencies"
  task :install do
    system('yarn install')
    exit $CHILD_STATUS.exitstatus
  end
end

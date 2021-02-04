admin_users = %w(sample)
  .map.with_index { |name, i| {id: i + 1, name: name.capitalize, email: name + '@example.com', password: 'test', role: (name.to_s.include?('special') ? 'special' : 'admin') }}
Admin::User.seed_once(:id, *admin_users)

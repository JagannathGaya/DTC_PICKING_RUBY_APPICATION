if User.count == 0
  admin_user = User.create(email: 'admin@example.com', password: 'password', name: 'Adam Administrator', empno: 'A100', user_type: 'admin')
  admin_user.save!

  user = User.create(email: 'user@example.com', password: 'password', name: 'Ulysses User', empno: 'U101', user_type: 'host', )
  user.save!
end


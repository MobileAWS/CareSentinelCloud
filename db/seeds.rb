# Basic info for all the environments

adminRole = Role.new
adminRole.name = 'Administrator'
adminRole.save

# Create the admin user
user = User.new
user.email = 'admin@caresentinel.com'
user.password = '@ndr0m3d@'
user.password_confirmation = '@ndr0m3d@'
user.customer_id = 0
user.skip_confirmation!
user.role = adminRole;
user.save!
# Basic info for all the environments

site = Site.new
site.name = 'default'
site.save

siteTwo = Site.new
siteTwo.name = 'test'
siteTwo.save

customerAdmin = Customer.new
customerAdmin.customer_id = 0
customerAdmin.save!

customerUser = Customer.new
customerUser.customer_id = 7
customerUser.save!

adminRole = Role.new
adminRole.name = 'Administrator'
adminRole.role_id = 'admin'
adminRole.save

caregiverRole = Role.new
caregiverRole.name = 'Caregiver'
caregiverRole.role_id = 'caregiver'
caregiverRole.save

caregiverAdminRole = Role.new
caregiverAdminRole.name = 'CaregiverAdmin'
caregiverAdminRole.role_id = 'caregiveradmin'
caregiverAdminRole.save

# Create the admin user
user = User.new
user.email = 'admin@caresentinel.com'
user.password = 'Polaris2014*'
user.password_confirmation = 'Polaris2014*'
user.skip_confirmation!
user.role = adminRole;
user.save!

customerUserAdmin = CustomerUser.new
customerUserAdmin.user = user
customerUserAdmin.customer = customerAdmin
customerUserAdmin.save!

siteUser = SiteUser.new
siteUser.site = site
siteUser.user = user
siteUser.save!

siteUser = SiteUser.new
siteUser.site = siteTwo
siteUser.user = user
siteUser.save!

# Create the caregiver user
user = User.new
user.email = 'caregiver@caresentinel.com'
user.password = 'Polaris2014*'
user.password_confirmation = 'Polaris2014*'
user.skip_confirmation!
user.role = caregiverRole;
user.save!

customerUserCaregiver = CustomerUser.new
customerUserCaregiver.user = user
customerUserCaregiver.customer = customerUser
customerUserCaregiver.save!

siteUser = SiteUser.new
siteUser.site = site
siteUser.user = user
siteUser.save!

siteUser = SiteUser.new
siteUser.site = siteTwo
siteUser.user = user
siteUser.save!

user = User.new
user.email = 'caregiverb@caresentinel.com'
user.password = 'Polaris2014*'
user.password_confirmation = 'Polaris2014*'
user.skip_confirmation!
user.role = caregiverRole;
user.save!

customerUserCaregiver = CustomerUser.new
customerUserCaregiver.user = user
customerUserCaregiver.customer = customerUser
customerUserCaregiver.save!

siteUser = SiteUser.new
siteUser.site = site
siteUser.user = user
siteUser.save!

user = User.new
user.email = 'caregiveradmin@caresentinel.com'
user.password = 'Polaris2014*'
user.password_confirmation = 'Polaris2014*'
user.skip_confirmation!
user.role = caregiverAdminRole;
user.save!

customerUserCaregiver = CustomerUser.new
customerUserCaregiver.user = user
customerUserCaregiver.customer = customerUser
customerUserCaregiver.save!

siteUser = SiteUser.new
siteUser.site = site
siteUser.user = user
siteUser.save!

siteUser = SiteUser.new
siteUser.site = siteTwo
siteUser.user = user
siteUser.save!

config = SiteConfig.new
config.name = 'purge_days'
config.value = '45'
config.site = site
config.save!

config = SiteConfig.new
config.name = 'purge_days'
config.value = '45'
config.site = siteTwo
config.save!
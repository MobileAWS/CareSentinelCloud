# Basic info for all the environments

site = Site.new
site.name = 'default'
site.save

siteTwo = Site.new
siteTwo.name = 'test'
siteTwo.save

adminRole = Role.new
adminRole.name = 'Administrator'
adminRole.role_id = 'admin'
adminRole.save

caregiverRole = Role.new
caregiverRole.name = 'Caregiver'
caregiverRole.role_id = 'caregiver'
caregiverRole.save

# Create the admin user
user = User.new
user.email = 'admin@caresentinel.com'
user.password = 'Polaris2014*'
user.password_confirmation = 'Polaris2014*'
user.customer_id = 0
user.skip_confirmation!
user.role = adminRole;
user.save!

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
user.customer_id = 1
user.skip_confirmation!
user.role = caregiverRole;
user.save!

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
user.customer_id = 2
user.skip_confirmation!
user.role = caregiverRole;
user.save!

siteUser = SiteUser.new
siteUser.site = site
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
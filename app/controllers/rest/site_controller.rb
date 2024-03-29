class Rest::SiteController < Rest::SecureController

  AuthValidation.admin_access :site => [:list,:update,:delete]
  AuthValidation.public_access :site => [:suggestions]

  def list
     expose paginateObject(Site.not_deleted.all)
  end

  def create
    return if !checkRequiredParams(:name);
    site = Site.new
    site.name = params[:name].upcase
    site.save!
    expose 'done'
  end

  def update
    return if !checkRequiredParams(:site_id,:description);
    tmpSite = Site.find(params[:site_id]);

    if(tmpSite.nil?)
      expose :message=>'Site not found', :error=>true
      return
    end

    tmpSite.description = params[:description]
    tmpSite.save!
    expose 'done'
  end

  def delete
    return if !checkRequiredParams(:site_id);
    tmpSite = Site.find(params[:site_id]);
    tmpSite.deleted = true;
    tmpSite.save!
  end

  def suggestions
    return if !checkRequiredParams(:query);
    name = params[:query];
    search = Site.select('id as data','name as value').not_deleted.where("lower(sites.name) like '%#{name.downcase}%'");
    expose :suggestions => search
  end

end
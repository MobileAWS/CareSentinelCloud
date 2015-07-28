class Rest::CustomerController < Rest::SecureController

  AuthValidation.admin_access :site => [:list,:update,:delete]
  AuthValidation.public_access :site => [:suggestions]

  def list
     expose paginateObject(Customer.all)
  end

  def create
    return if !checkRequiredParams(:customer_number);
    customer = Customer.new
    customer.customer_id = params[:customer_number]
    customer.save!
    expose 'done'
  end

  def update
    return if !checkRequiredParams(:customer_id, :description);
    tmpCustomer = Customer.find(params[:customer_id]);
    if(tmpCustomer.nil?)
      expose :message=>'Customer not found', :error=>true
      return
    end
    tmpCustomer.description = params[:description]
    tmpCustomer.save!
    expose 'done'
  end

  def delete
    return if !checkRequiredParams(:customer_id);
    tmpCustomer = Customer.find(params[:customer_id]);
    if(tmpCustomer.nil?)
      error! :not_acceptable, :metadata => {:message => 'Customer not found'}
    end

    customerUsers = CustomerUser.find_by_customer_id params[:customer_id]
    if !customerUsers.nil?
      error! :not_acceptable, :metadata => {:message => 'Customer is associated to users'}
    end


    tmpCustomer.delete
    expose 'done'
  end

  def suggestions
  end

end
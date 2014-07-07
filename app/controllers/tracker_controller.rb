class TrackerController < ApplicationController
	require 'mechanize'
  # require 'rubygems'

  def index
  	# contains all summary
  	@welcome_msg ="Hello! Welcome to Flight Tracker!"
    
    # without this, index function does not have @summary
    # just want to grab current_user's ff info... so it's not @summary = Ff.all  
    # @summary = User.first.ffs # returns in an array
    @summary = User.find(current_user.id).ffs  
      # if (@ff_detail_id)
      #   @get_ff_details = Ff.find(@ff_detail_id)
      # end
    # print each on view
    end

  # for current exisitng ff record -> being activate by 'Get mileage button'
  # at ruby, passing <form action="/tracker/get_mileage/<%= detail.id %>" -> does not mean i have to pass the id on def line , like this
  # def get_mileage(params[:id])!!! -> :id got passed, just means that the value can be grabbed 
  def get_mileage
    # find ff_id in table Ff, return in an array
    # first, check if Ff.find(1).ff_no works in rails c first 
    ############ @ff_detail_id = params[:id] # this is for method index 

# testing:
    # render text: params[:id]
    get_ff_details = Ff.find(params[:id])
    # render text: get_ff_details  # see footnote ->"assigns" -> see @get_ff_details have been passed.
    # debugging, can only test one render at one time, cannot be used with redirect at the same time..
    # render text: get_ff_details.id
    # render text: get_ff_details.ff_no
    # render text: get_ff_details.password
    # render text: get_ff_details.points
    # render text: get_ff_details.airline
    
    ff_id = get_ff_details.id  # same as params[:id]
    # from airline's method, return mileage after webscraping

    mileage = get_sign_in_url(get_ff_details.ff_no, get_ff_details.password, get_ff_details.airline)
    
    # render text: mileage

    # need to add this back!!!!!!!!!!!!!!!!!!!
    Ff.find(ff_id).update_attributes(points: mileage)

    #  first -> update this mileage to db (ff_id is needed here)
    
    # pass all these data to grab correct url at method 'get_sign_in_url' -> then from there, pass to mechanize corresponding method 'american'/ 'southwest' where -> webscraping is taken place  

# second -> print all data again to index again (so ff_id is no longer needed)

# !!!!!!!!!!!!!!!!!!!!!!! remember to add it back!!!!
    redirect_to '/tracker' 

    # returning... all results from other  
  end

  def get_sign_in_url(ff_no, ff_password, ff_airline)
    if ff_airline == 'American' || ff_airline == 'american'
      american(ff_no, ff_password)

    elsif ff_airline == 'Southwest' || ff_airline == 'southwest'
      # pass this URL to the private function
      southwest(ff_no, ff_password)

    elsif ff_airline == 'United' || ff_airline == 'united'
      united(ff_no, ff_password)
    end
  end

  def adding_ff_now
  	@ff = Ff.new(ff_params)
    # render text: @ff
  	@ff.save
  	puts "!!!!!!user wants to add ff"
  	# add ff_params to model table...
  	# call url from another definition 
  	flash[:success] = "Frequent Flyer info is added successfully!"
  	
    redirect_to '/tracker'
  end

  def destroy
    # render text: "user wants to delete! this record"
    # at route - get '/tracker/destroy/:id' => "tracker#destroy" -> so anything got passed behind destroy, will be store as params[:id] here
    # params[:id]
    ff_record = Ff.find(params[:id])
    ff_record.destroy
    redirect_to '/tracker'  # go back to index where rails pull all db record again from scratch
  end

  private
  def ff_params
  	params.require(:ff).permit(:airline, :ff_no, :points, :user_id ,:password)
  end

    # after getting mileage from webscraping, bring it back to method 'get_mileage' -> at there -> update to the database (may need another separate function)
  def american(ff_no, ff_password)  
    # 2 things to do:
    #  first -> update this mileage to db (ff_id is needed here)
    # second -> print all data again to index again (so ff_id is no longer needed)
    # render text: ff_id
    agent = Mechanize.new
    agent.get('http://www.aa.com/homePage.do')
    form = agent.page.forms
    form = form[2]
    form.loginId = ff_no
    form.password = ff_password
    # puts YAML::dump(form)
    form.submit

    # agent.page.at('.account-info')
    # info.children[4]
    # if (agent.page.at('.account-info'))
      info = agent.page.at('.account-info')
      if info.nil? # means password/ username incorrect
        mileage = "Unmatch reward no. or password!"
      else
        # render text: info
        # info[4]
        # info.children[4]
        # info.children[7]
        # mileage = info.children[7].text
        # render text: mileage
        # need to take away spacing...
        mileage = info.children[7].text.split.join('')
        mileage = mileage.gsub(',','')
        agent.cookie_jar.clear! # for security reason, once grab the info, logoff
        # render text: mileage
        # puts '!!!!!!!!!!mileage is here!!!!!!!!!!!'
        # puts mileage  # when debugging, need puts need to be used with redirect_to '/tracker'
      end
      return mileage
    # else 
      # flash[:m_error] = "Frequent Flyer No / password does not match!"
    # end
  end

# where webscraping - gem 'mechanize' kicks in
  def southwest(ff_no, ff_password)
# test it on my own site , codes here and the ones i tried successfully on rails c directly talking to the airine site
      # render text: "made it to southwest function"
      agent = Mechanize.new
      # agent.get('http://www.southwest.com/?int=GNAVHOMELOGO')
      agent.get('http://www.southwest.com/?int=GNAVHOMELOGO')
      ## may not need this puts YAML::dump(agent_get)
      form = agent.page.form_with(:id=>"loyaltyLoginForm")
      # puts YAML::dump(form)
      form.credential = ff_no
      form.password = ff_password
      # form
      # puts YAML::dump(form)
      form.submit
      # agent.page.at('.availablePointsNumber')
      # info = agent.page.at('.availablePointsNumber') # grabs html with mileage... 
      info = agent.page.at('.availablePointsNumber')
      if info.nil?
        mileage = "Unmatch reward no. or password!"
      else
        # grab only the mileage (the text) not the html tags
        # render text: info # debugging
        # puts YAML::dump(info) # debugging
        # take away all the space around the mileage points
        # grab that info and store it to a variable - mileage
        mileage = info.text.split.join('')

  # when running the terminal with the airline site
  # ran into problem, only grab 2 i/o 2,706 , since it was a string 
        # puts "!!!!!!!!!!!!"
        # puts mileage.inspect # debugging
        mileage = mileage.gsub(',','')
        # mileage = mileage.to_i  
      
        puts mileage
        # render :text mileage.is_a? 'String'
        # return mileage , pass it to get_mileage where mileage will got saved to db
        agent.cookie_jar.clear!  # for security reason, once grab the info, logoff
      end  
      return mileage
     
      # redirect_to '/tracker/get_mileage'  # no need to redirect as at get_mileage is calling this function, and return the value.
   
     ### code here.. is different from the codes which i tested out...when interacting only w/ signing in to airline.come with terminal commands 
      # miles = info.text.split.join('')
  end


  def united(ff_no, ff_password)
    puts "!!!!!!!!User chose united airline to update!!!!!!!!"
    agent = Mechanize.new
    agent_get = agent.get('https://www.united.com/web/en-US/content/mileageplus/default.aspx')
    # puts YAML::dump(agent_get)
    
    # after grabbing the sigin page, do sth with it
    form = agent.page.forms
    # form.count
    form = form.first

    form["ctl00$ContentInfo$accountsummary$OpNum1$txtOPNum"] = ff_no
    form["ctl00$ContentInfo$accountsummary$OpPin1$txtOPPin"] = ff_password
    # form , check if user value is stored
    # # form debugging:
    # if form["ctl00$ContentInfo$accountsummary$OpNum1$txtOPNum"] == "CD568684"
    #   puts "!!!!!!!!!!!!!!!!!!!!"
    # else
    #   puts "value is not stored!!!!!!!!!!!!!!!!!!!!!!!"
    # end

    # since there are >1 submit button to click
    form.button_with(:value=>"Sign In")
    button = form.button_with(:value=>"Sign In")
    
    agent.submit(form,button)
# there are two id for recently login user and the rest
    info = agent.page.at('#ctl00_ContentInfo_AccountSummary_lblMileageBalanceNew')
    info1 = agent.page.at('#ctl00_ContentInfo_accountsummary_spanMPBalance')  #check if this id exist, if yes, means logged in successfully, as this id is found at actual site after login.

    if info.nil? && info1.nil?  #means both cannot be found
      mileage = "Unmatch reward no. or password!"
      # puts "!!!!!!!!!!!!!"
      # puts mileage
      # if info is not nil , then info1 must be nil in my case
    elsif info.nil?  #then info1 must not be nil here, then final_info = info1
      # puts "!!!!!lblMileageBalanceNew  XXxXXXXX!!!!"
      final_info = info1
      # puts final_info.text # debugging
      mileage = final_info.text 
      agent.cookie_jar.clear! # for security reason, once grab the info, logoff

    elsif info1.nil?
      # puts "!!!!!id spanMPBalance !!!!"
      final_info = info
      # puts final_info.text # debugging
      mileage = final_info.text 
      agent.cookie_jar.clear! # for security reason, once grab the info, logoff
    end 
      
    # mileage = info.text  returns => "985 "
    return mileage
   # redirect_to '/tracker' # for debuggin only, as 'puts' uses with 'redirect_to' .. otherwise error: missing template - DO NOT NEED THIS WHEN DEbugging is done!
  end
  
end

    
    # american airline page:
    # http://www.aa.com/homePage.do

    # southwest page:
    # http://www.southwest.com/?int=GNAVHOMELOGO

    # united: page:
    # Preferred:
    # https://www.united.com/web/en-US/content/mileageplus/default.aspx

    # alaska page:
    # http://www.alaskaair.com/

    # British airways page:
    # http://www.britishairways.com/travel/home/public/en_us

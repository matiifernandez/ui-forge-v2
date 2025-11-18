require 'faker'

puts "Cleaning up the database..."
Message.destroy_all
Chat.destroy_all
Component.destroy_all
Project.destroy_all
User.destroy_all
puts "database cleaned"

COMPONENT_TEMPLATES = [
  {
    name: "Banner",
    html_code: '<div class="banner" style="background-image: linear-gradient(rgba(0,0,0,0.4),rgba(0,0,0,0.4)), url(https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/background.png);"> <div class="container"> <h1>Le Wagon brings <strong>tech skills</strong> to <strong>creative people</strong>!</h1> <p>Change your life and learn to code at one of our campuses around the world.</p> <a class="btn btn-flat" href="#">Apply now</a> </div> </div>',
    css_code: '.banner { background-size: cover; background-position: center; padding: 150px 0; } .banner h1 { margin: 0; color: white; text-shadow: 1px 1px 3px rgba(0,0,0,0.2); font-size: 32px; font-weight: bold; } .banner p { font-size: 20px; color: white; opacity: .7; text-shadow: 1px 1px 3px rgba(0,0,0,0.2); }'
  },
  {
    name: "Navbar",
    html_code: '<div class="navbar navbar-expand-sm navbar-light navbar-lewagon"> <div class="container-fluid"> <a class="navbar-brand" href="#"> <img src="https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/logo.png" /> </a> <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"> <span class="navbar-toggler-icon"></span> </button> <div class="collapse navbar-collapse" id="navbarSupportedContent"> <ul class="navbar-nav me-auto"> <li class="nav-item active"> <a class="nav-link" href="#">Home</a> </li> <li class="nav-item"> <a class="nav-link" href="#">Messages</a> </li> <li class="nav-item dropdown"> <img class="avatar dropdown-toggle" id="navbarDropdown" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false" src="https://kitt.lewagon.com/placeholder/users/ssaunier" /> <div class="dropdown-menu dropdown-menu-end" aria-labelledby="navbarDropdown"> <a class="dropdown-item" href="#">Action</a> <a class="dropdown-item" href="#">Another action</a> <a class="dropdown-item" data-turbo-method="delete" href="#">Log out</a> </div> </li> </ul> </div> </div> </div>',
    css_code: '.navbar-lewagon { justify-content: space-between; background: white; } .navbar-lewagon .navbar-collapse { flex-grow: 0; } .navbar-lewagon .navbar-brand img { width: 40px; }'
  },
  {
    name: "Card Trip",
    html_code: '<div class="card-trip"> <img src="https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/greece.jpg" /> <div class="card-trip-infos"> <div> <h2>Title here</h2> <p>Short description here!</p> </div> <h2 class="card-trip-pricing">£99.99</h2> <img src="https://kitt.lewagon.com/placeholder/users/krokrob" class="card-trip-user avatar-bordered" /> </div> </div>',
    css_code: '.card-trip { overflow: hidden; background: white; box-shadow: 0 0 15px rgba(0,0,0,0.2); } .card-trip > img { height: 200px; width: 100%; object-fit: cover; } .card-trip h2 { font-size: 16px; font-weight: bold; margin: 0; } .card-trip p { font-size: 12px; opacity: .7; margin: 0; } .card-trip .card-trip-infos { padding: 16px; display: flex; justify-content: space-between; align-items: flex-end; position: relative; } .card-trip-infos .card-trip-user { position: absolute; right: 16px; top: -20px; width: 40px; }'
  },
  {
    name: "Card Product",
    html_code: '<div class="card-product"> <img src="https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/skateboard.jpg" /> <div class="card-product-infos"> <h2>Product name</h2> <p>Product description with <strong>relevant info</strong> only.</p> </div> </div>',
    css_code: '.card-product { overflow: hidden; height: 120px; background: white; box-shadow: 0 0 15px rgba(0,0,0,0.2); display: flex; align-items: center; } .card-product img { height: 100%; width: 120px; object-fit: cover; } .card-product h2 { font-size: 16px; font-weight: bold; margin: 0; } .card-product p { font-size: 12px; line-height: 1.4; opacity: .7; margin-bottom: 0; margin-top: 8px; } .card-product .card-product-infos { padding: 16px; }'
  },
  {
    name: "Alert (Success)",
    html_code: '<div class="flash flash-success alert alert-dismissible fade show" role="alert"> <span><strong>Yay!</strong> 🎉 you successfully signed in to our service.</span> <a data-bs-dismiss="alert" aria-label="Close"> <i class="fas fa-times"></i> </a> </div>',
    css_code: '.flash { padding: 16px 24px; display: flex; justify-content: space-between; align-items: center; background: white; box-shadow: 0 0 8px rgba(0,0,0,0.2); border-radius: 4px; margin: 8px; } .flash-success { border: 2px solid #1EDD88; }'
  },
  {
    name: "Avatar",
    html_code: '<img class="avatar-bordered" alt="avatar-bordered" src="https://kitt.lewagon.com/placeholder/users/sarahlafer" />',
    css_code: '.avatar { width: 40px; border-radius: 50%; } .avatar-large { width: 56px; border-radius: 50%; } .avatar-bordered { width: 40px; border-radius: 50%; box-shadow: 0 1px 2px rgba(0,0,0,0.2); border: white 1px solid; } .avatar-square { width: 40px; border-radius: 0px; box-shadow: 0 1px 2px rgba(0,0,0,0.2); border: white 1px solid; }'
  },
  {
    name: "Button",
    html_code: '<a class="btn btn-gradient" href="#">Start now</a>',
    css_code: '.btn-gradient { color: white; padding: 8px 24px; border-radius: 4px; font-weight: bold; background: linear-gradient(#167FFB, #0F60C4); transition: background 0.3s ease; border: 1px solid #0F60C4; } .btn-gradient:hover { background: linear-gradient(#147EFF, #0F67DA); color: white; }'
  },
  {
    name: "Card Category",
    html_code: '<div class="card-category" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url(https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/breakfast.jpg)"> Breakfast </div>',
    css_code: '.card-category { background-size: cover; background-position: center; height: 180px; display: flex; justify-content: center; align-items: center; color: white; font-size: 24px; font-weight: bold; text-shadow: 1px 1px 3px rgba(0,0,0,0.2); border-radius: 5px; box-shadow: 0 0 15px rgba(0,0,0,0.2); }'
  },
  {
    name: "Footer",
    html_code: '<div class="footer"> <div class="footer-links"> <a href="#"><i class="fab fa-github"></i></a> <a href="#"><i class="fab fa-instagram"></i></a> <a href="#"><i class="fab fa-facebook"></i></a> <a href="#"><i class="fab fa-twitter"></i></a> <a href="#"><i class="fab fa-linkedin"></i></a> </div> <div class="footer-copyright"> This footer is made with <i class="fas fa-heart"></i> at Le Wagon </div> </div>',
    css_code: '.footer { background: #F4F4F4; display: flex; align-items: center; justify-content: space-between; height: 100px; padding: 0px 50px; color: rgba(0,0,0,0.3); } .footer-links a { color: black; opacity: 0.15; text-decoration: none; font-size: 24px; padding: 0px 10px; } .footer-links a:hover { opacity: 1; } .footer .fa-heart { color: #D23333; }'
  },
  {
    name: "Notification",
    html_code: '<div class="notification"> <img src=\'https://kitt.lewagon.com/placeholder/users/arthur-littm\' class="avatar-large" /> <div class="notification-content"> <p><small>14th January</small></p> <p>Lorem ipsum dolor sit amet, <strong>consectetur</strong> adipisicing elit.</p> </div> <div class="notification-actions"> <a href="#">Edit <i class="fas fa-pencil-alt"></i></a> <a href="#">Delete <i class="far fa-trash-alt"></i></a> </div> </div>',
    css_code: '.notification { display: flex; align-items: center; margin-bottom: 8px; background: white; padding: 8px 16px; border: 1px solid rgb(235,235,235); } .notification .notification-content { flex-grow: 1; padding: 0 24px; }'
  },
  {
    name: "Search Form",
    html_code: '<form novalidate="novalidate" class="simple_form search" action="/" accept-charset="UTF-8" method="get"> <div class="search-form-control form-group"> <input class="form-control string required" type="text" name="search[query]" id="search_query" /> <button name="button" type="submit" class="btn btn-flat"> <i class="fas fa-search"></i> Search </button> </div> </form>',
    css_code: '.search-form-control { position: relative; } .search-form-control .btn { position: absolute; top: 8px; bottom: 8px; right: 8px; } .search-form-control .form-control { height: 3.5rem; box-shadow: 0 2px 6px rgba(0,0,0,0.08); border: 1px solid #E7E7E7; }'
  },
  {
    name: "Tabs",
    html_code: '<ul class="list-inline tabs-underlined"> <li> <a href="#" class="tab-underlined active">Bookings</a> </li> <li> <a href="#" class="tab-underlined">Requests</a> </li> <li> <a href="#" class="tab-underlined">Conversations</a> </li> </ul>',
    css_code: '.tabs-underlined { display: flex; align-items: center; } .tabs-underlined .tab-underlined { color: black; padding: 8px; margin: 8px; opacity: .4; cursor: pointer; text-decoration: none; border-bottom: 4px solid transparent; } .tabs-underlined .tab-underlined.active { opacity: 1; border-bottom: 3px solid #555555; }'
  },
  {
    name: "Cards Grid Layout",
    html_code: '<div class="cards"> <div class="card-category" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url(https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/breakfast.jpg)"> Breakfast </div> <div class="card-category" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url(https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/lunch.jpg)"> Lunch </div> <div class="card-category" style="background-image: linear-gradient(rgba(0,0,0,0.3), rgba(0,0,0,0.3)), url(https://raw.githubusercontent.com/lewagon/fullstack-images/master/uikit/dinner.jpg)"> Dinner </div> </div>',
    css_code: '.cards { display: grid; grid-template-columns: 1fr 1fr 1fr; grid-gap: 16px; } @media (min-width: 768px) { .cards { grid-template-columns: 1fr 1fr; } } @media (min-width: 992px) { .cards { grid-template-columns: 1fr 1fr 1fr; } }'
  }
]

puts "Creating a user..."

user = User.create!(email: "test@mail.com", password: "123456", password_confirmation: "123456")
puts "User created #{user.email}"


10.times do
  project = Project.create!(
    title: "Project: #{Faker::App.name}",
    description: Faker::Lorem.paragraph(sentence_count: 2),
    user: user
  )

  num_components = rand(3..12)
  components_to_add = COMPONENT_TEMPLATES.sample(num_components)
  components_to_add.each do |template|
    component = Component.create!(
      name: template[:name],
      html_code: template[:html_code],
      css_code: template[:css_code],
      project: project
    )
    chat = Chat.create!(component: component)
    Message.create!([
      {
        role: 'user',
        content: "Ok, now looks good, but let's add some borders to it",
        chat: chat
      },
      {
        role: 'agent',
        content: "Sure, success alert: border: 2px solid #FF5500;",
        chat: chat
      }
    ])
  end
  puts "-> Project '#{project.title}' created with #{num_components} components."
end
puts "Database seeding complete!"

puts "#{User.count} users, #{Project.count} projects, #{Component.count} components, #{Chat.count} chats, and #{Message.count} messages created."

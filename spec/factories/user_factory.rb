FactoryGirl.define do
  factory :user, :aliases => [:oto] do
  	name 'Oto'
    gender 'male'
  	loc [46.5580334, 15.614261] # Miklaveceva ulica 16, 2000 Maribor
  end

  factory :miha, :parent => :user do
  	name 'Miha'
    gender 'male'
  	loc [46.5575954, 15.6141147] # Miklavceva ulica 9, 2000 Maribor
  end

  factory :dejan, :parent => :user do
  	name 'Dejan'
    gender 'male'
  	loc [46.5564689, 15.6142921] # 5 Ledinkova ulica, Maribor, Slovenija
  end

  factory :grega, :parent => :user do
  	name 'Grega'
  	loc [46.5554004, 15.6153254] # Frankopanova ulica
  end

  factory :ana, :parent => :user do
  	name 'Ana'
    gender 'female'
  	loc [46.051516, 14.5063676] # Presernov trg 5, 1000 Ljubljana
  end

  factory :john, :parent => :user do
  	name 'John'
    gender 'male'
  	loc [40.7596513, -73.9846149] # NY
  end

end
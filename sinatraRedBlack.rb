require 'rubygems'
require 'sinatra'
load 'redblack.rb'
require 'haml'
$tree_out = []
$last_edit = ""
configure do
	$rbtree = RBTree.new
	$rbtree.pump(30,20,60,55)
end

before do headers "Content-Type" => "text/html; charset=utf-8" end


get '/' do
	$tree_out.clear
	$tree_out.push $rbtree.root
	haml :index
end

post '/add' do
	$lastEdit = "Added	#{params[:add]}"	
	$rbtree.add(params[:add].to_i)# rescue $lastEdit = "Add Failed"
	redirect '/'
end
post '/remove' do
	$lastEdit = "Removed #{params[:remove]}"	
	$rbtree.find_and_remove(params[:remove].to_i) # rescue $lastEdit = "Remove Failed"
	redirect '/'
end	

get '/clear' do
	$lastEdit = "Tree Cleared."
	$rbtree = RBTree.new
	redirect '/'
end


helpers do
	def text_input(lable, name, text="")
		%{<tr><td> #{lable}</td><td><input type="text" size="3" name="#{name}" value="#{text}">}
	end
end

__END__
@@layout
!!!
%head
	%title Red-Black Tree
%body{:style => "color: #417D6F; font: 18px/20px helvetica; text-align: center; background-color: #FFFFFF;"}	
	=yield

@@index
-for i in 0..$rbtree.height
	%table{:align => "center", :style => "width: 100%; text-align: center; "}
		%tr
			-(2**i).times do |index|
				-break if $tree_out.empty?
				-node = $tree_out.pop
				-$tree_out.insert(0,node.left)
				-$tree_out.insert(0,node.right)
				-color =  node.color.to_s
				%td{:style => "width: #{100/(2**i)}%; color: #{color}; font-size: #{(150-(15*i))}%; background-color: #F5F5F5;"}
					=(node.value.nil? ? "" : node.value.to_s)
		
						  
%p{:style => "color: gray;"}
	=$lastEdit
%form{:method => "POST", :action => "/add"}
	= text_input("Add Node:", "add", rand(500))
	%input{:type => "submit", :value => "go"}
%form{:method =>"POST", :action => "remove"}
	= text_input("Remove Node:", "remove", 60)
	%input{:type => "submit", :value => "go"}
%form{:method =>"GET", :action => "clear"}
	%input{:type => "submit", :value => "Clear Red-Black Tree"}
%a{:href => "http://github.com/harpastum/sinatra-rbtree"} Source Code (github)
		
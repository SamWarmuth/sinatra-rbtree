require 'rubygems'
require 'sinatra'
load 'redblack.rb'
require 'haml'
$tree_out = []
$last_edit = ""
configure do
	$rbtree = RBTree.new
	$rbtree.add_multiple(28,6,70,40,5,18)
end

before do headers "Content-Type" => "text/html; charset=utf-8" end

get '/' do
	$tree_out.clear
	$tree_out.push $rbtree.root
	haml :index
end
post '/add' do
	if $rbtree.contains?(params[:add])
		$lastEdit = "Error: #{params[:add]} already in tree."	
	else
		$rbtree.add(params[:add])# rescue $lastEdit = "Add Failed"
		$lastEdit = "Added	#{params[:add]}"	
	end
	redirect '/'
end
post '/remove' do
	if $rbtree.contains?(params[:remove])
		$rbtree.find_and_remove(params[:remove]) # rescue $lastEdit = "Remove Failed"
		$lastEdit = "Removed #{params[:remove]}"
	else
		$lastEdit = "Error: #{params[:remove]} not in tree."
	end
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
%h3
	Size = #{$rbtree.size}, Max Height = #{$rbtree.height}, Black-Height = #{$rbtree.black_height}.
-for i in 0..$rbtree.height-1
	%table{:align => "center", :style => "width: #{(2.0**$rbtree.height)*15}px; text-align: center; "}
		%tr
			-(2**i).times do |index|
				-break if $tree_out.empty?
				-node = $tree_out.pop
				-$tree_out.insert(0,node.left)
				-$tree_out.insert(0,node.right)
				-color =  node.color.to_s
				%td{:style => "width: #{100.0/(2**i)}%; color: #{color}; font-size: #{(150-(15*i))}%; background-color: #F5F5F5;"}
					=(node.value.nil? ? "" : node.value.to_s)				
						  
%p{:style => "color: gray;"}
	=$lastEdit
%form{:method => "POST", :action => "/add"}
	- new_add = rand(100)
	- until !$rbtree.contains?(new_add)||$rbtree.size > 75 
		- new_add=rand(100)
	= text_input("Add Node:", "add", new_add)
	%input{:type => "submit", :value => "go"}
%form{:method =>"POST", :action => "remove"}
	= text_input("Remove Node:", "remove")
	%input{:type => "submit", :value => "go"}
%form{:method =>"GET", :action => "clear"}
	%input{:type => "submit", :value => "Clear Red-Black Tree"}
%a{:href => "http://github.com/harpastum/sinatra-rbtree"} Source Code
		
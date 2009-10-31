require 'rubygems'
require 'sinatra'
require 'redblack'
require 'haml'
$tree_out = []
$last_edit = ""
configure do
	$rbtree = RBTree.new
end

before do headers "Content-Type" => "text/html; charset=utf-8" end


get '/' do
	$tree_out.clear
	$tree_out.push $rbtree.root unless $rbtree.root.nil?
	haml :index
end

post '/add' do
	$lastEdit = "Added	#{params[:add]}"	
	$rbtree.add(params[:add].to_i) rescue $lastEdit = "Add Failed"
	redirect '/'
end
post '/remove' do
	$lastEdit = "Removed #{params[:remove]}"	
	$rbtree.find_and_remove(params[:remove].to_i) rescue $lastEdit = "Remove Failed"
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
-for i in 0..$rbtree.height+1
	%table{:align => "center", :style => "width: 100%; text-align: center; "}
		%tr
			-(2**i).times do |index|
				-break if $tree_out.empty?
				-node = $tree_out.pop
				-$tree_out.insert(0,(node.left ? node.left : RBNode.new("-", node)))
				-$tree_out.insert(0,(node.right ? node.right : RBNode.new("-", node)))
				-color = node.value.to_s.eql?("-") ? "black" : node.color.to_s
				%td{:style => "width: #{100/(2**i)}%; color: #{color};"}
					= node.parent.value.to_s.eql?("-") ? "" : node.value.to_s rescue node.value.to_s
		%br/
						  
%br
=$lastEdit
%form{:method => "POST", :action => "/add"}
	= text_input("Add Node:", "add", rand(500))
	%input{:type => "submit", :value => "go"}
%form{:method =>"POST", :action => "remove"}
	= text_input("Remove Node:", "remove")
	%input{:type => "submit", :value => "go"}
%form{:method =>"GET", :action => "clear"}
	%input{:type => "submit", :value => "Clear Red-Black Tree"}
%a{:href => "http://github.com/harpastum/sinatra-rbtree"} Source Code (github)
		
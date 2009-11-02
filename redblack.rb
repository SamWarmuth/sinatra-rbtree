class RBNode
	attr_accessor :value, :color, :left, :right, :parent
	def initialize(value, parent=nil)
		@parent = parent
		@value = value
		@color = :red
	end
	def to_s
		str = value.to_s + '' +@color.to_s + ' '
		str << "(L:#{@left})" if @left
		str << " | " if @left && @right
		str << "(R:#{@right})" if @right
		str
	end
end

class NilNode < RBNode
	def initialize
		@value = nil
		@color = :black
	end
	def color=(value)
		color= :black
	end
end

class RBTree
	attr_accessor :root
	def initialize(root_value=nil)
		@nilNode = NilNode.new
		@nilNode.left = @nilNode
		@nilNode.right = @nilNode
		@nilNode.parent = @nilNode
		if root_value.nil?
			@root = @nilNode
		else
			@root = RBNode.new(root_value)
			@root.parent = @nilNode
			@root.left = @nilNode
			@root.right = @nilNode
		end
	end
	def add_multiple(*values)
		values.each do |value|
			self.add(value)
		end
	end
	def add(value)
		return false if contains?(value)
		active_node = RBNode.new(value)
		active_node.left = @nilNode
		active_node.right = @nilNode
		active_node.parent = @nilNode
		@root == @nilNode ?  @root=active_node : insert(active_node, root) 

		while active_node.parent.color == :red
			if active_node.parent == active_node.parent.parent.left
				uncle = active_node.parent.parent.right
				if uncle.color == :red
					active_node.parent.color = :black
					uncle.color = :black
					active_node.parent.parent.color = :red
					active_node = active_node.parent.parent
				else
					if active_node == active_node.parent.right
						active_node = active_node.parent
						left_rotate(active_node)
					end
					active_node.parent.color = :black
					active_node.parent.parent.color = :red
					right_rotate(active_node.parent.parent) if active_node.parent.parent.left != @nilNode
				end
			else
				uncle = active_node.parent.parent.left
				if uncle.color == :red
					active_node.parent.color = :black
					uncle.color = :black
					active_node.parent.parent.color = :red
					active_node = active_node.parent.parent
				else
					if active_node == active_node.parent.left
						active_node = active_node.parent
						right_rotate(active_node)
					end
					active_node.parent.color = :black
					active_node.parent.parent.color = :red
					left_rotate(active_node.parent.parent) if active_node.parent.parent.right != @nilNode
				end
			end
		end
		@root.color = :black
	end
	def insert(new_node, tree_node)	
		case (new_node.value <=> tree_node.value)
		when 1
			if tree_node.right != @nilNode
				insert(new_node, tree_node.right) 
			else
				tree_node.right = new_node
				new_node.parent = tree_node
			end
		when -1
			if tree_node.left != @nilNode
				insert(new_node, tree_node.left) 
			else
				tree_node.left = new_node
				new_node.parent=tree_node
			end		
		end
	end
	def left_rotate(root)
		pivot = root.right		
		root.right = pivot.left
		pivot.left.parent=root
		pivot.parent = root.parent
		if root.parent != @nilNode
			if root == root.parent.left
				root.parent.left = pivot
			else 
				root.parent.right = pivot
			end
		else
			@root = pivot
		end
		pivot.left = root
		root.parent = pivot
	end
	def right_rotate(root)
		pivot = root.left
		root.left = pivot.right
		pivot.right.parent=root
		pivot.parent = root.parent
		if root.parent != @nilNode
			if root == root.parent.right
				root.parent.right = pivot
			else 
				root.parent.left = pivot
			end
		else
			@root = pivot
		end
		pivot.right = root
		root.parent = pivot
	end
	def remove(node)
		if node.left == @nilNode || node.right == @nilNode
			y = node
		else
			y = successor(node)
		end
		y.left != @nilNode ? x = y.left : x = y.right
		x.parent = y.parent
		if y.parent == @nilNode
			@root = x
		else
			y == y.parent.left ? y.parent.left = x : y.parent.right = x
		end
		pop = node.value
		node.value = y.value if y != node  #Kills satellite data
		delete_fix(x) if y.color == :black
		return pop
	end
	def delete_fix(x)
		while x != @root && x.color == :black
			if x == x.parent.left
				w = x.parent.right
				if w.color == :red
					w.color = :black
					x.parent.color = :red
					left_rotate(x.parent)
					w = x.parent.right
				end
				if w.left.color == :black && w.right.color == :black
					w.color = :red
					x = x.parent
				else
					if w.right.color == :black
						w.left.color = :black
						w.color = :red
						right_rotate(w)
						w = x.parent.right
					end
					w.color = x.parent.color
					x.parent.color = :black
					w.right.color = :black
					left_rotate(x.parent)
					x = @root
				end
			else # DRY...ugh
				w = x.parent.left
				if w.color == :red
					w.color = :black
					x.parent.color = :red
					right_rotate(x.parent)
					w = x.parent.left
				end
				if w.right.color == :black && w.left.color == :black
					w.color = :red
					x = x.parent
				else
					if w.left.color == :black
						w.right.color = :black
						w.color = :red
						left_rotate(w)
						w = x.parent.left
					end
					w.color = x.parent.color
					x.parent.color = :black
					w.left.color = :black
					puts "the problem is"
					right_rotate(x.parent)
					puts "right rotate"
					x = @root
				end
			end
		end
	end
	def contains?(value, node=@root)
		return false if node == @nilNode
		case value <=> node.value
		when  0  then return node
		when  1  then contains?(value, node.right)
		when -1  then contains?(value, node.left) 
		end
	end
	def find_and_remove(value)
		node = contains?(value)
		node ? remove(node) : false
	end
	def successor(node)
		return minimum(node.right) if node.right != @nilNode
		y = node.parent
		while y != @nilNode && node = y.right
			x = y
			y = y.parent
		end
		return y
	end
	def minimum(node)
		while node.left != @nilNode
			node = node.left
		end
		node
	end
	def maximum(node)
		while node.right != @nilNode
			node = node.right
		end
		node
	end
	def height(node=@root, height=1)
		return 0 if node == @nilNode
		lheight = node.left != @nilNode ? height(node.left,height+1) : height
		rheight = node.right != @nilNode ? height(node.right,height+1) : height
		return [lheight, rheight].max
	end
	def black_height(node=@root, height=0)
	  return 0 if node == @nilNode
	  height += 1 if node.color == :black
	  return (node.left == @nilNode ? height : black_height(node.left,height))
	end
	def size(node=@root)
		stack = []
		stack.push node
		count = 0
		while !stack.empty?
			node = stack.pop
			count += 1
			stack.push node.left if node.left != @nilNode
			stack.push node.right if node.right != @nilNode
		end
		return count
	end
	def to_s
		puts @root.to_s
	end
	private :insert
end
class NilClass
	attr_accessor :color
	@color = :black
end
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

class RBTree
	attr_accessor :root
	def intialize(root=nil)
		@root = RBNode.new(root) 
	end
	def pump(*values)
		values.each do |value|
			self.add(value)
		end
	end
	def add(value)
		active_node = RBNode.new(value)
		@root ? insert(active_node, root) : @root=active_node
		# fix rule violations
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
					right_rotate(active_node.parent.parent) if active_node.parent.parent.left != nil
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
					left_rotate(active_node.parent.parent) if active_node.parent.parent.right != nil
				end
			end
		end
		@root.color = :black
	end
	def insert(new_node, tree_node)		
		case (new_node.value <=> tree_node.value)
		when nil
			puts "Something's wrong."
		when 1
			if tree_node.right 
				insert(new_node, tree_node.right) 
			else
				tree_node.right = new_node
				new_node.parent=tree_node
			end
		when -1
			if tree_node.left 
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
		pivot.left.parent=root unless pivot.left.nil?
		pivot.parent = root.parent
		if root.parent != nil
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
		pivot.right.parent=root unless pivot.right.nil?
		pivot.parent = root.parent
		if root.parent != nil
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
		if !node.left || !node.right
			y = node
		else
			y = successor(node)
		end
		y.left ? x = y.left : x = y.right
		x.parent = y.parent if x
		if !y.parent
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
					right_rotate(x.parent)
					x = @root
				end
			end
		end
	end
	
	
	def find_and_remove(value)
		node = contains?(value)
		node ? remove(node) : false
	end
	def contains?(value, node=@root)
		return false if !node
		case value <=> node.value
		when  0  then return node
		when  1  then contains?(value, node.right)
		when -1  then contains?(value, node.left) 
		end
	end
	def successor(node)
		return minimum(node.right) if node.right
		y = node.parent
		while y && node = y.right
			x = y
			y = y.parent
		end
		return y
	end
		
	def minimum(node)
		while node.left
			node = node.left
		end
		node
	end
	def maximum(node)
		while node.right
			node = node.right
		end
		node
	end
	def height(node=@root, height=0)
		return 0 if node.nil?
		lheight = node.left ? height(node.left,height+1) : height
		rheight = node.right ? height(node.right,height+1) : height
		return [lheight, rheight].max
	end
	def to_s
		puts @root.to_s
	end
	private :insert
end
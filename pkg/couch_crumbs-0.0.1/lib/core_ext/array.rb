class Array

  def destroy!
    each { |o| o.destroy }
  end
  
end
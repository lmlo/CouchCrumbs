class Array

  # Add a destroy all method to arrays
  #
  def destroy!
    each { |o| o.destroy! }
  end
  
end
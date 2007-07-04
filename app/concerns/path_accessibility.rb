module PathAccessibility
  def accessible_by?(user)
    return true  if (user && user.admin?) || changeset.repository.public?
    return false if user.nil?
    paths = user.permissions.paths_for(changeset.repository)
    paths == :all || paths.any? { |p| path == "#{p}" || path =~ %r{^#{p}/} }
  end
end
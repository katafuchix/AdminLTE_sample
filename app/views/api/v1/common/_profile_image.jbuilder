if profile_image
  json.approvable_status profile_image.image_status
  json.merge! profile_image.image_approval_values(browse_user: current_user)
  if profile_image.sort_order
    json.main profile_image.sort_order.zero?
    json.sort_order profile_image.sort_order
    json.image_role profile_image.image_role
  end
end

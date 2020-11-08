json.profile do
  json.merge! user_profile.actual_values(browse_user: current_user)
  #json.no_charging_member user_profile.user.no_charging_member?
  #json.normal_charging_member user_profile.user.normal_charging_member?
  #json.premium_charging_member user_profile.user.premium_charging_member?
  json.created_at user_profile.user.created_at
  json.deleted_at user_profile.user.deleted_at
  #json.current_sign_in_at user_profile.user.current_sign_in_at
  #json.unique_key user_profile.user.unique_key
end
json.incomming_relations_count user_profile.user.incomming_relations_count
#json.within_month_incomming_relation_count user_profile.user.within_month_incomming_relation_count
#json.within_week_incomming_relation_count user_profile.user.within_week_incomming_relation_count
json.incomming_matches_count user_profile.user.incomming_matches_count
json.incomming_favorites_count user_profile.user.incomming_favorites_count
json.outcomming_relations_count user_profile.user.outcomming_relations_count
json.outcomming_matches_count user_profile.user.outcomming_matches_count
json.outcomming_favorites_count user_profile.user.outcomming_favorites_count
#json.room_id current_user.mutual_matchs
#                          .detect{|s| s.user_id == user_profile.user.id || s.target_user_id == user_profile.user.id}
#                          .try(:room_id)

json.merge! current_user.self_association_with_user(user_profile.user)

json.profile_images user_profile.profile_images do |profile_image|
  json.partial! partial: 'v1/common/profile_image', locals: { user_profile: user_profile, profile_image: profile_image }
end

json.public_main_image user_profile.public_sub_image?(user_profile.profile_images.first.presence, browse_user: current_user)
json.main_image_role user_profile.profile_images.first.try(:image_role) || ProfileImage.image_roles.keys.first
json.default_icon user_profile.main_image_url if user_profile.profile_images.blank?

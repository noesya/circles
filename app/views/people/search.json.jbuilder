json.array! @people do |person|
  json.id person.id
  json.name person.to_s
  json.status person.status.strip.presence
  json.url person_path(person)
end

#!/usr/bin/env ruby
require 'xcodeproj'

PROJECT_PATH = '/Users/apple/Desktop/Personal Project/Expense_Tracking_App/Expense_Tracking_App.xcodeproj'
APP_DIR = '/Users/apple/Desktop/Personal Project/Expense_Tracking_App/Expense_Tracking_App'

new_files = [
  # Models
  'Models/KhataPerson.swift',
  'Models/KhataEntry.swift',
  # Realm Models
  'Models/Realm/KhataPersonObject.swift',
  'Models/Realm/KhataEntryObject.swift',
  # Services
  'Services/RealmManager+Khata.swift',
  # ViewModels
  'ViewModels/KhataViewModel.swift',
  # Views
  'Views/Khata/KhataView.swift',
  'Views/Khata/AddPersonSheet.swift',
  'Views/Khata/KhataDetailView.swift',
  'Views/Khata/AddEntrySheet.swift',
]

project = Xcodeproj::Project.open(PROJECT_PATH)

target = project.targets.find { |t| t.name == 'Expense_Tracking_App' }
unless target
  puts "❌ Could not find target 'Expense_Tracking_App'"
  exit 1
end

main_group = project.main_group.groups.find { |g| g.name == 'Expense_Tracking_App' || g.path == 'Expense_Tracking_App' }
unless main_group
  puts "❌ Could not find main group"
  exit 1
end

puts "✅ Found target: #{target.name}"
puts "✅ Found main group: #{main_group.name || main_group.path}"

def find_or_create_group(parent_group, path_components)
  return parent_group if path_components.empty?

  component = path_components.first
  rest = path_components[1..]

  existing = parent_group.groups.find { |g| (g.name || g.path) == component }
  group = existing || parent_group.new_group(component)
  find_or_create_group(group, rest)
end

new_files.each do |relative_path|
  full_path = File.join(APP_DIR, relative_path)

  unless File.exist?(full_path)
    puts "⚠️  Skipping (not found): #{relative_path}"
    next
  end

  already_added = project.files.any? { |f| f.real_path.to_s == full_path rescue false }
  if already_added
    puts "ℹ️  Already in project: #{relative_path}"
    next
  end

  path_parts = relative_path.split('/')
  file_name = path_parts.last
  dir_parts = path_parts[0..-2]

  group = find_or_create_group(main_group, dir_parts)
  file_ref = group.new_file(full_path)
  file_ref.path = file_name
  file_ref.source_tree = '<group>'
  file_ref.last_known_file_type = 'sourcecode.swift'

  target.source_build_phase.add_file_reference(file_ref)
  puts "✅ Added: #{relative_path}"
end

project.save
puts "\n🎉 Khata files added to Xcode project successfully!"

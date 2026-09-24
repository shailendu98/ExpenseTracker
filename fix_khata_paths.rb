#!/usr/bin/env ruby
require 'xcodeproj'

PROJECT_PATH = '/Users/apple/Desktop/Personal Project/Expense_Tracking_App/Expense_Tracking_App.xcodeproj'
APP_DIR = '/Users/apple/Desktop/Personal Project/Expense_Tracking_App/Expense_Tracking_App'

project = Xcodeproj::Project.open(PROJECT_PATH)

target = project.targets.find { |t| t.name == 'Expense_Tracking_App' }
main_group = project.main_group.groups.find { |g| g.name == 'Expense_Tracking_App' || g.path == 'Expense_Tracking_App' }

puts "✅ Found target: #{target.name}"
puts "✅ Found main group: #{main_group.name || main_group.path}"

# Files that were wrongly registered (without Khata subfolder)
bad_files = [
  'AddEntrySheet.swift',
  'AddPersonSheet.swift',
  'KhataDetailView.swift',
  'KhataView.swift',
]

# Step 1: Remove bad references from build phase and project
puts "\n--- Removing bad file references ---"
bad_files.each do |fname|
  # Search all file references in the project
  project.files.each do |file_ref|
    path = file_ref.real_path.to_s rescue nil
    next unless path

    # Wrong if the path ends with Views/<fname> (not Views/Khata/<fname>)
    if path.end_with?("/Views/#{fname}")
      puts "🗑  Removing bad ref: #{path}"
      # Remove from build phases
      target.source_build_phase.files_references.each do |ref|
        if ref == file_ref
          target.source_build_phase.remove_file_reference(file_ref)
          break
        end
      end
      # Remove from group
      file_ref.remove_from_project
    end
  end
end

# Step 2: Find or create Views/Khata group
def find_or_create_group(parent_group, path_components)
  return parent_group if path_components.empty?
  component = path_components.first
  rest = path_components[1..]
  existing = parent_group.groups.find { |g| (g.name || g.path) == component }
  group = existing || parent_group.new_group(component)
  find_or_create_group(group, rest)
end

# Step 3: Re-add with correct paths under Views/Khata
puts "\n--- Re-adding with correct paths ---"
correct_files = [
  'Views/Khata/KhataView.swift',
  'Views/Khata/AddPersonSheet.swift',
  'Views/Khata/KhataDetailView.swift',
  'Views/Khata/AddEntrySheet.swift',
]

correct_files.each do |relative_path|
  full_path = File.join(APP_DIR, relative_path)

  unless File.exist?(full_path)
    puts "⚠️  File not found on disk: #{full_path}"
    next
  end

  # Check if already correctly registered
  already = project.files.any? do |f|
    (f.real_path.to_s rescue nil) == full_path
  end
  if already
    puts "ℹ️  Already correctly registered: #{relative_path}"
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
  puts "✅ Added correctly: #{relative_path}"
end

project.save
puts "\n🎉 Project fixed and saved!"

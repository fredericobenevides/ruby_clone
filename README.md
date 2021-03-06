# **RubyClone** - Simplifying the use of Rsync

**RubyClone** was designed to be simple, easy, clean and a high level script for RSync.

## Installation

Install the gem:

`gem install ruby_clone`

Create a file that is named '.ruby_clone' in your home folder and set up a profile.
**NOTE**: Don't forget to use the dot in the file.

And then execute:

`$ ruby_clone my_profile`

You can also specify another path of your **RubyClone** file:

`$ ruby_clone -b /my/ruby_clone_file my_profile`

## Usage

### Basic Configuration

To start using it, you'll need to create the following configuration in your **RubyClone** file.

**NOTE**: The folder of from configurations needs to have the last slash. If it doesn't have, it will copy the
'source_folder' inside the 'destination_folder'. (This behaviour is from RSync)

**NOTE 2**: If your source folder/destination_folder has spaces as "My Source Folder", you need to set up it as
"My\\ Source\\ Folder" with **two back slashes** for **each space**. Spaces and only one back slash will not work.

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder"
end
```

If you set up this configuration in your $HOME/.ruby_clone, you can run with:

`$ ruby_clone my_profile`

If is in another path, run with:

`$ ruby_clone -b /my/backup_file my_profile`

**NOTE**: This basic setup doesn't sync deleted files from the source folder. If you want to delete them, you need
to setup the option 'delete: true'.

### SSH

**RubyClone** offers the option to use SSH in a easy way. You just need to use the option ':ssh' with the 'user@host'.
Example for SSH that is on source folder.

```ruby
profile :my_profile do
  from "/my/source_folder/", ssh: "user@source_server"
  to "/my/destination_folder"
end
```

Example for SSH that is on destination folder:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", ssh: "user@destination_server"
end
```

After running one of theses profiles, you just need to type the password.

## Improving your **RubyClone** file

**RubyClone** aims to be simple and be readable for you when you set up it. All the new configurations that you
can set up was created with this in mind.

Here is all the configuration you can set up and improve your **RubyClone** file.

### Excluding a Pattern - exclude_pattern "pattern"

If you need to exclude folders or files matching a pattern, use the 'exclude_pattern command.
This command can be used in two ways: On the top of **RubyClone** file and/or inside the 'from'.
Here a complete example:

```ruby
exclude_pattern "top_pattern"

profile :my_profile1 do
  from "/my/source_folder/"
  to "/my/destination_folder"
end

profile :my_profile2 do
  from "/my/source_folder/" do
    exclude_pattern "from_pattern"
  end
  to "/my/destination_folder"
end
```

1. 'my_profile1' will exclude only the "top_pattern".
2. 'my_profile2' will exclude the "top_pattern" and "from_pattern"

### Including a Pattern - include_pattern "pattern"

Same as the exclude_pattern. If you need to include folders or files matching a pattern, use the
include_pattern command. This command can be use in two ways: On the top of **RubyClone** file and/or
inside the 'from' block. Example:

```ruby
include_pattern "top_pattern"

profile :my_profile1 do
  from "/my/source_folder/"
  to "/my/destination_folder"
end

profile :my_profile2 do
  from "/my/source_folder/" do
    include_pattern "from_pattern"
  end
  to "/my/destination_folder"
end
```

1. 'my_profile1' will include only the "top_pattern".
2. 'my_profile2' will include the "top_pattern" and "from_pattern"

Here an example using exclude_pattern and include_pattern together. In this example, :my_profile will exclude
all folders and will sync/include only the 'from_pattern'

```ruby
profile :my_profile do
  from "/my/source_folder/" do
    exclude_pattern "*"
    include_pattern "from_pattern"
  end
  to "/my/destination_folder"
end
```

### Deleting files

* Deleting files that don't exist in source_folder but in destination folder - delete: true

The basic configuration was created to be a secure configuration. So if you really want to delete files/folders
in your destination folder that doesn't exist anymore in your source folder, you'll need to set up 'delete: true' in
your **RubyClone** file. Below an example how to do it:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true
end
```

Now all files that exists in "/my/destination_folder/" but "/my/source_folder" will be deleted. If for some
reason you want to keep some files and delete others, just set up the exclude_pattern inside 'from' block.

* Deleting files that are excluded from source folder to destination folder - delete_excluded: true

If you decided to exclude files from the syncronization but they still in your destination folder, you can use
the 'delete_excluded' to delete this files inside destination folder that are excluded from the source_folder.
Example:

```ruby
profile :my_profile do
  from "/my/source_folder/" do
    exclude_pattern "my_pattern"
  end
  to "/my/destination_folder", delete_excluded: true
end
```

Now all files that are inside destination_folder that have the pattern 'my_pattern' will be deleted.

**NOTE**: When you use 'delete_excluded :true' you don't need to set up 'delete: true' even the from
configuration doesn't have the 'exclude_pattern'

### Backuping files - backup "folder"

* If you want to save all the files that get **updated** and **deleted**, you need to set up the 'backup'
configuration inside the 'to' block. Example:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true do
    backup "/my/backup_folder"
  end
end
```


Now all the folders/files that get **updated** or **deleted** in the "/my/destination_folder" will be moved to
"/my/backup_folder".  The files moved to "/my/destination_folder" will have a default suffix that is a **RubyClone**
control key plus the Date with the format: "yyyyMMdd".

All files that are saved in the "/my/backup_folder" will have a limit of 5 files. So if any file that passed this
limit, the old file will be deleted. You can change this limit using the option "limit".

**NOTE**: The **RubyClone** control key is a special key to use as a control to remove old duplicated files.

* Changing the suffix of the files inside the backup folder - backup "folder", suffix: "my_suffix"

If you want to change the Date suffix for the files that you backup, you need to set the 'suffix' as a parameter to 'backup'.
Example:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true do
    backup "/my/backup_folder", suffix: "my_suffix"
  end
end
```

Another example using suffix with the Time class of Ruby to generate the date with timestamp "yyyyMMdd_hhmmss" :

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true do
    backup "/my/backup_folder", suffix: "_#{Time.now.strftime("%Y%m%d_%H%M%S")}"
  end
end
```

**NOTE**: Changing the suffix will not change the **RubyClone** control key. Since this key control how to remove the
old duplicated files.

* Disabling the default suffix - backup "folder", disable_suffix: true

If for some reason you want to disable the file suffix in the backup folder you can set true for 'default_true'. Doing
that all the files that are moved to "/my/backup_folder" will have the same name and it will get override by a new file.
Example:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true do
    backup "/my/backup_folder", disable_suffix: true
  end
end
```

**NOTE**: This kind of setup will **backup only one file** and nothing more.

* Changing how many files you want to backup - backup "folder", limit: 10

**RubyClone** have a default to save 5 files "/my/backup_folder" that have the same name. If you want to change the
limit you just need to set up the option limit with the number of files to save.
Example:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true do
    backup "/my/backup_folder", limit: 20
  end
end
```

Now "/my/backup_folder" will save 20 files with the same name.

* Disabling the limit of files to save. Save unlimited files - backup "folder", limit: :unlimited

If for some reason you want to backup all files that are **updated** or **deleted** you need to set up the 'limit'
option with ':unlimited'
Example:

```ruby
profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder", delete: true do
    backup "/my/backup_folder", limit: :unlimited
  end
end
```

Now all files will be saved, until you change the 'limit' to a specific number to erased all the old files that passed
the new limit.

### Disabling the output commands of RSync - config options

*  **RubyClone** offers the possibility to not show the rsync command generated (show_command) and rsync output
(show_output). To use it, you need to set up in the top of your **RubyClone** file the 'config' and the commands you
want to disable. Example:

```ruby
config show_command: false, show_output: false

profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder"
end
```

The above config will not show anymore the rsync command and rsync outputs. But errors will keep showing if
happen.

* Overriding the default configuration of Rsync command - config options: 'override_options'

If you need to override the default configurations for RSync you can set up the "config options: 'my_options'".
Example:

```ruby
config options: '-Cav --stats'

profile :my_profile do
  from "/my/source_folder/"
  to "/my/destination_folder"
end
```

## Running

**RubyClone** as default will try to read the **RubyClone** file in your home folder: $HOME/.ruby_clone. If you
need to specify another path of your **RubyClone** file don't forget to add the option -b

`$ ruby_clone -b /my/ruby_clone_file profile`

RSync offers the options to dry-run the command and just run the sincronization as a simulation. You can do this
too with **RubyClone**. Just pass the option '-d' to ruby_clone

`$ ruby_clone -d profile`

## More interesting **RubyClone** file

Here a interesting **RubyClone** file that you can improve.

**NOTE**: Don't forget that the folder of from configuration needs to have the last slash. If it doesn't have,
it will copy the 'source_folder' inside the 'destination_folder. (This behaviour is from RSync)

**NOTE 2**: If your source folder/destination_folder has spaces as "/My Source Folder", you need to set up it as
"My\\ Source\\ Folder" with **two back slashes** for **each space**. Spaces and only one back slash will not work.

```ruby
profile :my_profile do
  from "/my/source_folder/" do
    exclude_pattern "pattern"
  end
  to "/my/destination_folder", delete_excluded: true do
    backup "/my/backup"
  end
end
```

## Contributing to **RubyClone**

* Fork, fix, then send me a pull request.

## Copyright

Copyright (c) 2012 Frederico Benevides. See MIT-LICENSE for further details.
# Meal plan history sperlunking

For the last few years I've kept a meal plan in Apple notes. Each one is a separate note looking something like this:

```
2023-01-30

- Falafels
- Maangchi pork belly
- Leftovers
- Veg wraps
- Chicken gyros (https://www.bbcgoodfood.com/recipes/chicken-gyros)
- Jacket potatoes with beans, cheese and something tasty
- Clearout

```

There are a few variations, and some contain shopping lists, lunch lists, or short notes saying we'll be away somewhere to make planning/shopping easier.

I want to see patterns in how we eat (or at least plan to), and resurface popular but forgotten meals from years gone by.

> This is a tool I hacked together for [Remote Hack](https://remotehack.space). It is hacky and could do anything. Don't trust it!

## Running the tool

1. Export the notes using [this](http://writeapp.net/notesexporter/). Place them in the `icloud_notes_export` directory.

2. Run `bundle` if you haven't already, to install the dependencies.

3. Run `bundle exec ruby summarise_meal_plans.rb`

## Naming assumptions

I've been working with a flat export so we can't use the folder location to identify meal plan notes.

Instead we match on notes that are exactly "YYYY-MM-DD" in Apple Notes.

This translates to `Notes[YYYY-MM-DD].txt` in the export.

## Export notes from iCloud

### HTML export with an unchecked tool

We can export notes from Apple Notes with [this](http://writeapp.net/notesexporter/). It's not great – everything is exported into a flat folder structure, but it's HTML so easier to parse :)

### Direct access to the notes SQLite database

iCloud-synced notes are stored in `~/Library/Containers/com.apple.Notes/Data/CloudKit/cloudd_db/`.

There are three files:
- `db`, contains the data we're after in an SQLite database
- `db.shm`, indexes for the write-ahead log
- `db.wal`, the write-ahead log

We can inspect the data with [Datasette](datasette.io).

The database doesn't _look_ like it contains anything useful :(.
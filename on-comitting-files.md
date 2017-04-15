I don't like losing work, which is why I like Git, but also I don't want to do the whole cutting-commits thing, and I don't want auto-comitting

or actually, though, do I? like that might honestly just be the thing to do, set up a Cron job that just commits if there's uncommitted changes, and adds all files

well okay though the thing is, I don't want to have buffer saving as a step, if that's what I'm doing

but I guess I could just turn on auto-save in this workspace

ok done, now the next step would be the cron script thing

---

ok so I've got that, but I'm not wild about the style yet. what I'd really like would be something that inotifywaits the whole directory, and starts a shotclock on like a ten-or-twenty second interval, and basically starts staging once we've started making changes, and commits and pushes once we've stopped making changes

or maybe the inotifywait just makes the index check, and then we reset the clock every time there's an inotification, and then once the clock is up we add and commit push

also maybe the commit message should be the datetime and/or time elapsed since last commit


i think the simplest way, to make it so inotifywait and timeout don't have to come in as deps, is to just do ten-second sleep loops on the check, have a priming function that populates the index, and then fires after X cycles have gone by with no changes from the index or something like that

also, should pro

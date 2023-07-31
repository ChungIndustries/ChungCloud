local LOG_PATH = "/update_log.txt"

local SYSTEM_REPO_CREDENTIALS = {
    "authToken": "REDACTED",
    "user": "chrille0313",
    "repo": "ChungCloud"
}

local REPOS = {
    {
        "authToken": "REDACTED", 
        "user": "chrille0313", 
        "repo": "ChungIndustries"
    },
}

local UPDATE_RATE = 30


function load_logs()
    return json.decodeFromFile(LOG_PATH)
end


function log_update(authToken, user, repo)
    local latestCommitDate = github.get_latest_commit(authToken, user, repo).commit.committer.date
    local logs = load_logs()
    logs[repo] = latestCommitDate
    json.encodeToFile(logs, LOG_PATH)
end


function update_repo(credentials)
    print("Downloading update...")
    github.download_repo(table.unpack(credentials))
    print("Download complete!")

    print("Refactoring repo...")

    shell.run("delete /cloud/"..credentials.repo.."/")
    shell.run("move /downloads/"..credentials.repo.." /cloud/")

    print("Refactoring complete!")
end


function update_system()
    print("Downloading update...")
    github.download_repo(table.unpack(SYSTEM_REPO_CREDENTIALS))
    print("Download complete!")

    print("Refactoring system..")

    shell.run("delete main.lua")
    shell.run("delete startup.lua")
    shell.run("delete update.lua")
    shell.run("delete update_client.lua")

    shell.run("move /downloads/ChungCloud/* /")
    shell.run("delete /downloads/ChungCloud/")

    print("Refactoring complete!")

    shell.run("reboot")
end


log_update(table.unpack(SYSTEM_REPO_CREDENTIALS))

while true do
    local logs = load_logs()

    print("Checking for repo updates...")
    
    for _, credentials in pairs(REPOS) do
        if github.check_for_updates(table.unpack(credentials), logs[credentials.repo]) then
            print("Repo update found!")
            update_repo()
        end
    end

    print("Checking for system updates...")

    if github.check_for_updates(table.unpack(SYSTEM_REPO_CREDENTIALS), logs[SYSTEM_REPO_CREDENTIALS.repo]) then
        print("System update found!")
        update_system()
    end

    print("No updates found. Sleeping for " ..UPDATE_RATE.." seconds...")

    sleep(UPDATE_RATE)
end

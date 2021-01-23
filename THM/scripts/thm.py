#!/usr/bin/env python3
# Author: superhero1 ( Twitter: @_superhero1 )
# Version: 1.1
# Description: Get a list of all TryHackMe rooms including points and if you have completed them, leaderboard and current rank
# Prerequisites: run pip install thmapi
# License: MIT

import argparse
from time import sleep
from datetime import datetime
from thmapi import THM
from thmapi.util import http_get

def this_month(published_date):
    first_of_this_month = datetime.today().date().replace(day=1)
    return True if published_date.date() >= first_of_this_month else False

def get_points(room_info):
    tasks = t.room_tasks(room_info['code'])
    points_per_question = 30 if room_info['type'] == 'challenge' else 8
    points = 0
    for task in tasks:
        for q in task['tasksInfo']:
            if q['noAnswer'] == False:
                points += points_per_question
                points += q['extraPoints']
    published_date = datetime.fromisoformat(room_info['published'].replace("Z", "+00:00"))
    monthly = 0
    if (this_month(published_date) == True and room_info['type'] == 'challenge') or (this_month(published_date) == True and room_info['type'] == 'walkthrough'):
        monthly = points
    elif this_month(published_date) == False and room_info['type'] == 'challenge':
        monthly = int(points / 30 * 8)
    return [points, monthly]

def main():
    if (args.rank):
        endpoint = '/api/leaderboards?type=monthly' if args.monthly else '/api/leaderboards'
        ranks = http_get(t.session, endpoint)
        message = 'Your monthly rank is:' if args.monthly else 'Your alltime rank is:'
        print(message, ranks['usersRank'])
    elif (args.leaderboard):
        endpoint = '/api/leaderboards?type=monthly' if args.monthly else '/api/leaderboards'
        ranks = http_get(t.session, endpoint)
        user_ranks = ranks['ranks']
        users = []
        for user in user_ranks:
            username = user['username']
            alltimePoints = user['points']
            monthlyPoints = user['monthlyPoints']
            users.append((username, alltimePoints, monthlyPoints))
        
        sort_by = 2 if args.monthly else 1
        reverse_me = False if args.asc else True
        print('username alltime monthly')
        for user in sorted(users, key=lambda x: x[sort_by], reverse=reverse_me):
            print(user[0], user[1], user[2]) #this way it can be easily imported into sheets
    else:
        endpoint = '/api/hacktivities'
        hacktivities = http_get(t.session, endpoint)
        rooms = []

        for room_info in hacktivities:
            points = get_points(room_info)
            room = (room_info['code'], points[0], points[1], room_info['userCompleted'])
            rooms.append(room)
            sleep(1)

        sort_by = 2 if args.monthly else 1
        reverse_me = False if args.asc else True

        print('roomcode alltime monthly completed')
        for room in sorted(rooms, key=lambda x: x[sort_by], reverse=reverse_me):
            print(room[0], room[1], room[2], room[3]) #this way it can be easily imported into sheets

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--session", help="connect.sid", required=True)
parser.add_argument("-m", "--monthly", action='store_true', help="Sort for monthly, alltime is default")
parser.add_argument("-a", "--asc", action='store_true', help="Sort ascending, descending is default")
parser.add_argument("-l", "--leaderboard", action='store_true', help="Query the leaderboard instead of rooms")
parser.add_argument("-r", "--rank", action='store_true', help="Query the userrank")

args = parser.parse_args()
credentials = {}
credentials['session'] = args.session
t = THM(credentials)

if __name__ == "__main__":
    main()

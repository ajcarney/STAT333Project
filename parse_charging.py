#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 15 14:55:31 2024

@author: aiden
"""

import pandas as pd
import requests
import json



df = pd.read_csv("STAT333Project/data/alt_fuel_stations.csv")

import concurrent.futures


urls = [] # input URLs/IPs array
responses = {} # output content of each request as string in an array

# get urls
for index, row in df.iterrows():
    lat = row["Latitude"]
    lon = row["Longitude"]
    
    
    url = "https://geo.fcc.gov/api/census/area?lat={lat}&lon={lon}&format=json".format(lat=lat, lon=lon)
    urls.append(url)


def send(url):
    responses.update({url:requests.get(url)})

print(len(urls))
with concurrent.futures.ThreadPoolExecutor(max_workers=10000) as executor:
    futures = []
    for url in urls:futures.append(executor.submit(send, url))
    
    
print(len(responses))


i = 0
for index, row in df.iterrows():
    lat = row["Latitude"]
    lon = row["Longitude"]
    
    url = "https://geo.fcc.gov/api/census/area?lat={lat}&lon={lon}&format=json".format(lat=lat, lon=lon)
    
    try:
        res = responses.get(url)
        data = json.loads(res.text)
        
        county = data["results"][0]["county_name"]
        
        
        df.loc[index, 'county'] = county
    

    except:
        try:
            print(res.text)
        except:
            pass
        print(index)
        i += 1

    
df.to_csv("test.csv")

print(i, "failed")
    

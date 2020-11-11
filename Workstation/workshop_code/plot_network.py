# -*- coding: utf-8 -*-
"""
Created on Mon Nov  9 20:19:59 2020

@author: lenovo
"""

import json
import os

from pyecharts import options as opts
from pyecharts.charts import Graph, Page


nodes = [
        {"name": "结点1", "symbolSize": 10},
        {"name": "结点2", "symbolSize": 20},
        {"name": "结点3", "symbolSize": 30},
        {"name": "结点4", "symbolSize": 40},
        {"name": "结点5", "symbolSize": 50},
        {"name": "结点6", "symbolSize": 40},
        {"name": "结点7", "symbolSize": 30},
        {"name": "结点8", "symbolSize": 20},
    ]
links = []
for i in nodes:
        for j in nodes:
            links.append({"source": i.get("name"), "target": j.get("name")})

graph= (
        Graph()
        .add("", nodes, links, repulsion=8000)
        .set_global_opts(title_opts=opts.TitleOpts(title="Graph-基本示例"))
    )
graph.render()
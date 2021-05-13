# frozen_string_literal: true

require 'ruby-graphviz'

g = GraphViz.new(:G, type: :digraph)

u = g.add_nodes('user')
u_unconfirmed = g.add_nodes('unconfirmed user')
u_confirmed = g.add_nodes('confirmed user')
u_confirmed_choose_dialog = g.add_nodes('confirmed user choose dialog')
u_unconfirmed_choose_dialog = g.add_nodes('unconfirmed user choose dialog')
u_confirmed_application = g.add_nodes('confirmed user applied')
u_provided_additional_info = g.add_nodes('user provided additional info')

g.add_edge(u, u_unconfirmed, label: 'provide email')
g.add_edge(u_unconfirmed, u_confirmed, label: 'confirm email')
g.add_edge(u_unconfirmed, u_unconfirmed_choose_dialog, label: 'choose application')
g.add_edge(u_confirmed, u_confirmed_choose_dialog, label: 'choose application')
g.add_edge(u_unconfirmed_choose_dialog, u_unconfirmed, label: 'apply, show warning')
g.add_edge(u_confirmed_choose_dialog, u_confirmed_application, label: 'apply')
g.add_edge(u_confirmed_application, u_provided_additional_info, label: 'provide more info')

g.output(png: 'user_application_fsm.png')

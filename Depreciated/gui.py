#!/usr/bin/env python3
from router import Router

from nicegui import ui


@ui.page('/')  # normal index page (e.g. the entry point of the app)
@ui.page('/{_:path}')  # all other pages will be handled by the router but must be registered to also show the SPA index page
def main():
    router = Router()

    @router.add('/WordChain')
    def show_game():
        ui.label('Game Content').classes('text-2xl')

    @router.add('/How to Play')
    def show_rules():
        ui.label('Rules Content').classes('text-2xl')


    @router.add('/Statistics')
    def show_stats():
        ui.label('Statistics Content').classes('text-2xl')

    @router.add('/Settings')
    def show_settings():
        ui.label('Settings Content').classes('text-2xl')

    # adding some navigation buttons to switch between the different pages
    with ui.row():
        ui.button('WordChain', on_click=lambda: router.open(show_game)).classes('w-32')
        # ui.button('How to Play', on_click=lambda: router.open(show_rules)).classes('w-32')
        with ui.button('How to Play'):
            ui.tooltip('Game Rules:').classes('bg-green', 'text-2xl')
        ui.button('Statistics', on_click=lambda: router.open(show_stats)).classes('w-32')
        ui.button('Settings', on_click=lambda: router.open(show_settings)).classes('w-32')
        ui.label()

    # this places the content which should be displayed
    router.frame().classes('w-full p-4 bg-gray-100')


ui.run()
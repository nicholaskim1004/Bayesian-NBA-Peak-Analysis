import time
import pickle
import requests
from nba_api.stats.static import players
from nba_api.stats.endpoints import commonplayerinfo

class CollegeInfo:
    def __init__(self, info_dict_path='player_info_dict.pkl'):
        self.info_dict_path = info_dict_path
        
        # Try loading existing dictionary, otherwise make empty one
        try:
            with open(info_dict_path, 'rb') as f:
                self.info_dict = pickle.load(f)
        except FileNotFoundError:
            self.info_dict = {}

    def get_player_info(self, player_id, retries=3, delay=30):
        for attempt in range(retries):
            try:
                time.sleep(delay)
                return commonplayerinfo.CommonPlayerInfo(player_id=player_id)
            except requests.exceptions.ReadTimeout:
                if attempt < retries - 1:
                    time.sleep(delay * 2)
                else:
                    raise

    def fill_in_info(self, cur_players, player_w_info):
        for player in cur_players:
            if player not in player_w_info:
                try:
                    if player in self.info_dict:
                        continue

                    # Search player full name
                    result = players.find_players_by_full_name(player)

                    if not result:
                        print("Could not find:", player)
                        self.info_dict[player] = {'College': 'NA', 'Draft Pick': 'NA'}
                        continue

                    player_id = result[0]["id"]

                    # Pull info
                    player_info = self.get_player_info(player_id)
                    info = player_info.common_player_info.get_data_frame()

                    college = info.loc[0, "SCHOOL"]
                    draft_pick = info.loc[0, "DRAFT_NUMBER"]

                    self.info_dict[player] = {
                        'College': college,
                        'Draft Pick': draft_pick
                    }

                except Exception as e:
                    print("Failed:", player, "| Reason:", e)
                    self.info_dict[player] = {'College': 'NA', 'Draft Pick': 'NA'}

                time.sleep(15)

        print("Saving pulled info...")
        with open(self.info_dict_path, 'wb') as f:
            pickle.dump(self.info_dict, f)

        return self.info_dict

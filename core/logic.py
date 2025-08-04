import json

from core.state import check_current_year, stat_state

def load_config():
    """Load config dynamically to respect changes"""
    with open("config.json", "r", encoding="utf-8") as file:
        config = json.load(file)
    return config

# Get priority stat from config
def get_stat_priority(stat_key: str) -> int:
    config = load_config()
    priority_stat = config["priority_stat"]
    return priority_stat.index(stat_key) if stat_key in priority_stat else 999

# Check if any training has enough support cards
def has_sufficient_support(results):
    config = load_config()
    max_failure = config["maximum_failure"]
    min_support = config.get("min_support", 0)
    
    for stat, data in results.items():
        if int(data["failure"]) <= max_failure:
            # Special handling for WIT - requires at least 2 support cards regardless of MIN_SUPPORT
            if stat == "wit":
                if data["total_support"] >= 2:
                    return True
            # For non-WIT stats, check against MIN_SUPPORT
            elif data["total_support"] >= min_support:
                return True
    return False

# Check if all training options have failure rates above maximum
def all_training_unsafe(results):
    config = load_config()
    max_failure = config["maximum_failure"]
    
    for stat, data in results.items():
        if int(data["failure"]) <= max_failure:
            return False
    return True

# Will do train with the most support card
# Used in the first year (aim for rainbow)
def most_support_card(results):
    config = load_config()
    max_failure = config["maximum_failure"]
    min_support = config.get("min_support", 0)
    do_race_when_bad_training = config.get("do_race_when_bad_training", True)
    
    # Seperate wit
    wit_data = results.get("wit")

    # Get all training but wit
    non_wit_results = {
        k: v for k, v in results.items()
        if k != "wit" and int(v["failure"]) <= max_failure
    }

    # Check if train is bad
    all_others_bad = len(non_wit_results) == 0

    if all_others_bad and wit_data and int(wit_data["failure"]) <= max_failure and wit_data["total_support"] >= 2:
        print("\n[INFO] All trainings are unsafe, but WIT is safe and has enough support cards.")
        return "wit"

    filtered_results = {
        k: v for k, v in results.items() if int(v["failure"]) <= max_failure
    }
    
    # Remove WIT if it doesn't have enough support cards
    if "wit" in filtered_results and filtered_results["wit"]["total_support"] < 2:
        print(f"\n[INFO] WIT has only {filtered_results['wit']['total_support']} support cards. Excluding from consideration.")
        del filtered_results["wit"]

    if not filtered_results:
        print("\n[INFO] No safe training found. All failure chances are too high.")
        return None

    # Best training
    best_training = max(
        filtered_results.items(),
        key=lambda x: (
            x[1]["total_support"],
            -get_stat_priority(x[0])  # priority decides when supports are equal
        )
    )

    best_key, best_data = best_training

    # Skip MIN_SUPPORT check if do_race_when_bad_training is disabled
    if do_race_when_bad_training and best_data["total_support"] < min_support:
        if int(best_data["failure"]) == 0:
            print(f"\n[INFO] Only {best_data['total_support']} support but 0% failure. Prioritizing based on priority list: {best_key.upper()}")
            return best_key
        else:
            print(f"\n[INFO] Low value training (only {best_data['total_support']} support). Choosing to rest.")
            return None

    print(f"\nBest training: {best_key.upper()} with {best_data['total_support']} support cards and {best_data['failure']}% fail chance")
    return best_key

# Do rainbow training
def rainbow_training(results):
    config = load_config()
    max_failure = config["maximum_failure"]
    
    # Get rainbow training
    rainbow_candidates = {
        stat: data for stat, data in results.items()
        if int(data["failure"]) <= max_failure and data["support"].get(stat, 0) > 0
    }

    if not rainbow_candidates:
        print("\n[INFO] No rainbow training found under failure threshold.")
        return None

    # Find support card rainbow in training
    best_rainbow = max(
        rainbow_candidates.items(),
        key=lambda x: (
            x[1]["support"].get(x[0], 0),
            -get_stat_priority(x[0])
        )
    )

    best_key, best_data = best_rainbow
    print(f"\n[INFO] Rainbow training selected: {best_key.upper()} with {best_data['support'][best_key]} rainbow supports and {best_data['failure']}% fail chance")
    return best_key

def filter_by_stat_caps(results, current_stats):
    config = load_config()
    stat_caps = config["stat_caps"]
    
    return {
        stat: data for stat, data in results.items()
        if current_stats.get(stat, 0) < stat_caps.get(stat, 1200)
    }
  
# Decide training (with race prioritization)
def do_something(results):
    config = load_config()
    do_race_when_bad_training = config.get("do_race_when_bad_training", True)
    min_support = config.get("min_support", 0)
    max_failure = config["maximum_failure"]
    
    year = check_current_year()
    current_stats = stat_state()
    print(f"Current stats: {current_stats}")

    filtered = filter_by_stat_caps(results, current_stats)

    if not filtered:
        print("[INFO] All stats capped or no valid training.")
        return None

    if "Pre-Debut" in year:
        return most_support_card(filtered)
    else:
        result = rainbow_training(filtered)
        if result is None:
            print("[INFO] Falling back to most_support_card because rainbow not available.")
            # Check if any training has sufficient support cards (only when do_race_when_bad_training is true)
            if do_race_when_bad_training:
                if not has_sufficient_support(filtered):
                    print(f"\n[INFO] No training has sufficient support cards (min: {min_support}) or safe failure rates (max: {max_failure}%). Prioritizing race instead.")
                    return "PRIORITIZE_RACE"
            else:
                print(f"\n[INFO] do_race_when_bad_training is disabled. Skipping support card requirements and proceeding with training.")
            
            return most_support_card(filtered)
    return result

# Decide training (without race prioritization - fallback)
def do_something_fallback(results):
    year = check_current_year()
    current_stats = stat_state()
    print(f"Current stats: {current_stats}")

    filtered = filter_by_stat_caps(results, current_stats)

    if not filtered:
        print("[INFO] All stats capped or no valid training.")
        return None

    if "Pre-Debut" in year:
        return most_support_card(filtered)
    else:
        result = rainbow_training(filtered)
        if result is None:
            print("[INFO] Falling back to most_support_card because rainbow not available.")
            return most_support_card(filtered)
    return result

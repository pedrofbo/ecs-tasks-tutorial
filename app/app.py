import os
import time


if __name__ == "__main__":
    print(f"Running with execution ID {os.environ.get('EXECUTION_ID')}")
    for i in range(60 * 60 * 24):
        if i % 15000 == 0:
            print(i)
        time.sleep(1)
    print("task ended")

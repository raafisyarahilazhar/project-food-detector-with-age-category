from ultralytics import YOLO

model = YOLO("models/food_v1.pt")


def detect(image_path):

    results = model(image_path)

    output = []

    for r in results:

        for b in r.boxes:

            conf = float(b.conf)

            if conf > 0.5:

                output.append({
                    "label": r.names[int(b.cls)],
                    "confidence": conf
                })

    return output
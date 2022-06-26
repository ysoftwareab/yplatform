A product import from a supplier is put on an existing S3 bucket in our AWS account every
morning at approximately 3AM. The data is in CSV format and contains approximately 10,000
products.

Use appropriate AWS services to design a system that in a fast, resilient and cost effective way
processes the CSV file, turns each row into JSON and allows for other microservices to subscribe to
the products.

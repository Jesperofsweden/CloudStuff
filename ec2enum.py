import boto3
import base64

def list_instances(profile, region):
    session = boto3.Session(profile_name=profile)
    ec2 = session.client('ec2', region_name=region)

    instances = ec2.describe_instances()
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            instance_id = instance['InstanceId']
            print(f"---------------------------💥{instance_id}💥-------------------------------\n")

            # Print instance Name tag
            if 'Tags' in instance:
                name_tag = next((tag['Value'] for tag in instance['Tags'] if tag['Key'] == 'Name'), None)
                if name_tag:
                    print(f"Instance Name: {name_tag}")

            # Decode and print user data
            attribute = ec2.describe_instance_attribute(InstanceId=instance_id, Attribute='userData')
            user_data = attribute['UserData']
            if 'Value' in user_data:
                decoded_user_data = base64.b64decode(user_data['Value']).decode('utf-8')
                print(decoded_user_data)
            print("\n")

def main():
    profile = input("📦 Enter AWS profile name: ")

    session = boto3.Session(profile_name=profile)
    ec2 = session.client('ec2')

    regions = [region['RegionName'] for region in ec2.describe_regions()['Regions']]
    
    for region in regions:
        print(f"Processing Region: {region}")
        list_instances(profile, region)

if __name__ == "__main__":
    main()

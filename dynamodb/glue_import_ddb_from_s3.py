import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Script generated for node Amazon S3
source = glueContext.create_dynamic_frame.from_options(
    format_options={},
    connection_type="s3",
    format="parquet",
    connection_options={
        "paths": ["s3://aws-glue-assets-702626449187-us-west-2/run-DataSink0-1-part-block-0-r-00000-snappy.parquet"],
        "recurse": False},
    transformation_ctx="source"
)

# {
#     "Item": {
#         "Code": {
#             "S": "M.1621834854.A.84E"
#         },
#         "Title": {
#             "S": "[閒聊] 加密貨幣行情閒聊區-牛熊僅有一線之隔"
#         },
#         "Date": {
#             "S": ""
#         },
#         "Comments": {
#             "S": "[{\"Tag\":\"→ \",\"UserID\":\"illidan9999\",\"Content\":\": 已開新串\",\"DateTime\":\"2021-05-27T14:39:00+08:00\"}]"
#         },
#         "Author": {
#             "S": ""
#         },
#         "LastPushDateTime": {
#             "S": "2021-05-27T14:39:00+08:00"
#         },
#         "Link": {
#             "S": "https://www.ptt.cc/bbs/DigiCurrency/M.1621834854.A.84E.html"
#         },
#         "ID": {
#             "N": "1621834854"
#         },
#         "Board": {
#             "S": "DigiCurrency"
#         },
#         "PushSum": {
#             "N": "0"
#         }
#     }
# }

mapped = ApplyMapping.apply(frame=source, mappings=[
    ("item.Code.S", "string", "Code", "string"),
    ("item.Title.S", "string", "Title", "string"),
    ("item.Date.S", "string", "Date", "string"),
    ("item.Comments.S", "string", "Comments", "string"),
    ("item.Author.S", "string", "Author", "string"),
    ("item.LastPushDateTime.S", "string", "LastPushDateTime", "string"),
    ("item.Link.S", "string", "Link", "string"),
    ("item.ID.N", "integer", "ID", "integer"),
    ("item.Board.S", "string", "Board", "string"),
    ("item.PushSum.N", "integer", "PushSum", "integer")],
    transformation_ctx="mapped")

mapped.show()

glueContext.write_dynamic_frame_from_options(
    frame=mapped,
    connection_type="dynamodb",
    connection_options={
        "dynamodb.output.tableName": "articles",
        "dynamodb.throughput.write.percent": "1.0"
    }
)

job.commit()

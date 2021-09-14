#!/bin/bash
export CUDA_VISIBLE_DEVICES=2
DATA_DIR="data/STC_data_pro"
CHECKPOINT_PATH="models/STC/CPM_test"
RESULTS_DIR="results/"
MODEL_NAME="finetune-dial-large-fp32"
TOKENIZER_PATH="bpe_3w_new/"
MPSIZE=2
NLAYERS=32
NHIDDEN=2560
NATT=32
MAXSEQLEN=200

CUR_PATH=$(realpath $0)
CUR_DIR=$(dirname ${CUR_PATH})
DS_CONFIG="${CUR_DIR}/../ds_config/ds_finetune_lm_large_fp32.json"
python3 -m torch.distributed.launch --master_port 1111 --nproc_per_node 1 finetune_lm.py \
       --do_train \
       --do_eval \
       --data_dir ${DATA_DIR} \
       --model-parallel-size ${MPSIZE} \
       --num-layers ${NLAYERS} \
       --hidden-size ${NHIDDEN} \
       --load ${CHECKPOINT_PATH} \
       --num-attention-heads ${NATT} \
       --seq-length ${MAXSEQLEN} \
       --max-position-embeddings 1024 \
       --tokenizer-type GPT2BPETokenizer \
       --tokenizer-path ${TOKENIZER_PATH} \
       --vocab-size 30000 \
       --lr 0.00001 \
       --warmup 0.1 \
       --batch-size 16 \
       --deepspeed \
       --deepspeed_config ${DS_CONFIG} \
       --log-interval 10 \
       --eval-interval 100 \
       --seed 23333 \
       --results_dir ${RESULTS_DIR} \
       --model_name ${MODEL_NAME} \
       --epoch 1 \
       --checkpoint-activations \
       --deepspeed-activation-checkpointing
